import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import 'storage_service.dart';

/// API Response wrapper
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

/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Base API Service
class ApiService {
  static ApiService? _instance;
  final StorageService _storage = StorageService();

  ApiService._internal();

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Global Accept-Language so backend returns title/description/labels in user's language
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.languageKey) ?? 'sw';
    headers['Accept-Language'] = lang;
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(
          queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
        );
      }
      print('API GET: $uri'); // Debug log
      final response = await http
          .get(uri, headers: await _getHeaders(requiresAuth: requiresAuth))
          .timeout(AppConstants.apiTimeout);
      print('API Response: ${response.statusCode}'); // Debug log
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw ApiException('Hakuna mtandao. Tafadhali angalia internet yako.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw ApiException('Muda umekwisha. Tafadhali jaribu tena.');
    } on HandshakeException catch (e) {
      print('HandshakeException (SSL): $e');
      throw ApiException('Tatizo la SSL. Tafadhali wasiliana na msaada.');
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw ApiException('Jibu la server si sahihi.');
    } catch (e) {
      print('Unknown Error: $e');
      throw ApiException('Hitilafu: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('API POST: $uri'); // Debug log
      print('Body: $body'); // Debug log
      final response = await http
          .post(
            uri,
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);
      print(
          'API Response: ${response.statusCode} - ${response.body}'); // Debug log
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw ApiException('Hakuna mtandao. Tafadhali angalia internet yako.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw ApiException('Muda umekwisha. Tafadhali jaribu tena.');
    } on HandshakeException catch (e) {
      print('HandshakeException (SSL): $e');
      throw ApiException('Tatizo la SSL. Wasiliana na msaada.');
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw ApiException('Jibu la server si sahihi.');
    } catch (e) {
      print('Unknown Error: $e');
      throw ApiException('Hitilafu: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http
          .put(
            uri,
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw ApiException('Hakuna mtandao. Tafadhali angalia internet yako.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw ApiException('Muda umekwisha. Tafadhali jaribu tena.');
    } on HandshakeException catch (e) {
      print('HandshakeException (SSL): $e');
      throw ApiException('Tatizo la SSL. Wasiliana na msaada.');
    } catch (e) {
      print('Unknown Error: $e');
      throw ApiException('Hitilafu: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, dynamic>? files,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          if (entry.value is XFile) {
            final file = entry.value as XFile;
            final bytes = await file.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(entry.key, bytes,
                  filename: file.name),
            );
          } else if (entry.value is File) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }
      }
      final streamedResponse = await request.send().timeout(
            AppConstants.uploadTimeout,
          );
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw ApiException('Hakuna mtandao. Tafadhali angalia internet yako.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw ApiException('Muda umekwisha. Tafadhali jaribu tena.');
    } catch (e) {
      print('Upload Error: $e');
      throw ApiException('Imeshindwa kupakia: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, dynamic>? files,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('PUT', uri);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          if (entry.value is XFile) {
            final file = entry.value as XFile;
            final bytes = await file.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(entry.key, bytes,
                  filename: file.name),
            );
          } else if (entry.value is File) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }
      }
      final streamedResponse = await request.send().timeout(
            AppConstants.uploadTimeout,
          );
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw ApiException('Hakuna mtandao. Tafadhali angalia internet yako.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw ApiException('Muda umekwisha. Tafadhali jaribu tena.');
    } catch (e) {
      print('Upload Error: $e');
      throw ApiException('Imeshindwa kupakia: ${e.toString()}');
    }
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final dynamic body = jsonDecode(response.body);

      Map<String, dynamic> bodyMap;
      if (body is List) {
        bodyMap = {'data': body, 'success': true};
      } else if (body is Map<String, dynamic>) {
        bodyMap = body;
      } else {
        throw ApiException('Jibu la server si sahihi.');
      }

      final success = response.statusCode >= 200 && response.statusCode < 300;
      final message = bodyMap['message'] as String?;

      if (!success) {
        // Get validation errors if any
        String errorMsg =
            message ?? 'Hitilafu imetokea. Tafadhali jaribu tena.';
        if (bodyMap['errors'] != null) {
          final errors = bodyMap['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMsg = firstError.first.toString();
          }
        }
        throw ApiException(errorMsg, response.statusCode);
      }

      return ApiResponse(
        success: success,
        data: bodyMap,
        message: message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print('Response parsing error: $e');
      print('Response body: ${response.body}');
      throw ApiException('Jibu la server si sahihi: ${response.statusCode}');
    }
  }
}
