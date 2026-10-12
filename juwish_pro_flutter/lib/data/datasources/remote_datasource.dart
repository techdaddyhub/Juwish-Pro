import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class RemoteDataSource {
  final ApiClient _client;

  RemoteDataSource({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Map<String, dynamic>?> getSyncInfo() async {
    final response = await _client.get(ApiEndpoints.syncInfo);
    if (response.success && response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<dynamic>> getPlans() async {
    final response = await _client.get(ApiEndpoints.plans);
    if (response.success &&
        response.data is Map &&
        response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getTickers() async {
    final response = await _client.get(ApiEndpoints.tickers);
    if (response.success &&
        response.data is Map &&
        response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  }

  Future<ApiResponse<dynamic>> login(String email, String password) async {
    return await _client.post(ApiEndpoints.login, body: {
      'email': email,
      'password': password,
    });
  }

  Future<ApiResponse<dynamic>> submitKyc({
    required String fullName,
    required String idType,
    required String idNumber,
  }) async {
    return await _client.post(ApiEndpoints.userKyc, body: {
      'full_name': fullName,
      'id_type': idType,
      'id_number': idNumber,
    });
  }
}
