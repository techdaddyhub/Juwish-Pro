import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/secure_storage_service.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final http.Client _httpClient;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient({http.Client? client}) : _httpClient = client ?? http.Client();
  ApiClient._internal() : _httpClient = http.Client();

  Map<String, String> _buildHeaders({String? token}) {
    final activeToken = token ?? _storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (activeToken != null) 'Authorization': 'Bearer $activeToken',
    };
  }

  Future<ApiResponse<dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response =
          await _httpClient.get(uri, headers: _buildHeaders()).timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Network offline. Using cached state.',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Connection timed out. Retrying...',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Network offline. Check internet connection.',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Connection timed out.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  ApiResponse<dynamic> _handleResponse(http.Response response) {
    dynamic decodedData;
    try {
      decodedData = jsonDecode(response.body);
    } catch (_) {
      decodedData = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: true,
        data: decodedData,
        statusCode: response.statusCode,
      );
    } else {
      String message = 'HTTP Error ${response.statusCode}';
      if (decodedData is Map && decodedData['message'] != null) {
        message = decodedData['message'].toString();
      }
      return ApiResponse(
        success: false,
        data: decodedData,
        message: message,
        statusCode: response.statusCode,
      );
    }
  }
}
