import 'dart:async';
import '../../core/utils/biometric_helper.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isBiometricAvailable;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isBiometricAvailable = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isBiometricAvailable,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
    );
  }
}

class AuthBloc {
  final AuthRepository _repository;
  final _stateController = StreamController<AuthState>.broadcast();

  AuthState _state = const AuthState();
  AuthState get state => _state;
  Stream<AuthState> get stream => _stateController.stream;

  AuthBloc({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl() {
    _init();
  }

  void _emit(AuthState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _init() async {
    _emit(_state.copyWith(status: AuthStatus.loading));
    final bioAvailable = await BiometricHelper.isBiometricAvailable();
    final currentUser = await _repository.getCurrentUser();
    if (currentUser != null) {
      _emit(_state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
        isBiometricAvailable: bioAvailable,
      ));
    } else {
      _emit(_state.copyWith(
        status: AuthStatus.unauthenticated,
        isBiometricAvailable: bioAvailable,
      ));
    }
  }

  Future<bool> login(String email, String password) async {
    _emit(_state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.login(email, password);
      if (user != null) {
        _emit(_state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
        return true;
      } else {
        _emit(_state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid credentials or network failure.',
        ));
        return false;
      }
    } catch (e) {
      _emit(_state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    final success = await BiometricHelper.authenticateWithBiometrics(
      promptMessage:
          'Authenticate with FaceID or Fingerprint to unlock JuwishPro',
    );
    if (success && _state.user != null) {
      _emit(_state.copyWith(status: AuthStatus.authenticated));
      return true;
    }
    return false;
  }

  Future<bool> submitKyc({
    required String fullName,
    required String idType,
    required String idNumber,
    required String documentFilePath,
  }) async {
    _emit(_state.copyWith(status: AuthStatus.loading));
    final success = await _repository.submitKyc(
      fullName: fullName,
      idType: idType,
      idNumber: idNumber,
      documentFilePath: documentFilePath,
    );
    if (success && _state.user != null) {
      final updatedUser = UserEntity(
        id: _state.user!.id,
        name: fullName,
        email: _state.user!.email,
        role: _state.user!.role,
        kycStatus: 'Approved',
        jwcBalance: _state.user!.jwcBalance,
        usdBalance: _state.user!.usdBalance,
        referralCode: _state.user!.referralCode,
        twoFactorEnabled: _state.user!.twoFactorEnabled,
      );
      _emit(_state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      ));
      return true;
    }
    _emit(_state.copyWith(status: AuthStatus.authenticated));
    return success;
  }

  Future<void> logout() async {
    await _repository.logout();
    _emit(_state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
