import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> get token async => _storage.read(key: _tokenKey);
  Future<void> saveToken(String t) => _storage.write(key: _tokenKey, value: t);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Map<String, String> _headers(String? t) => {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      };

  Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    throw HttpException(
      '${res.statusCode}: ${body is Map ? (body['detail'] ?? body.toString()) : body}',
    );
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final t = await token;
    final res = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(t),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final t = await token;
    final res = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(t),
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(res);
  }

  Future<List<dynamic>> getList(String path) async {
    final t = await token;
    final res = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(t),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    final body = jsonDecode(res.body);
    throw HttpException(
      '${res.statusCode}: ${body is Map ? (body['detail'] ?? body.toString()) : body}',
    );
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final t = await token;
    final res = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(t),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final t = await token;
    final res = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers(t),
        )
        .timeout(ApiConfig.timeout);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path,
    File file, {
    String fieldName = 'archivo',
    Map<String, String>? extraFields,
  }) async {
    final t = await token;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}$path'),
    );
    if (t != null) request.headers['Authorization'] = 'Bearer $t';
    request.files.add(
      await http.MultipartFile.fromPath(fieldName, file.path),
    );
    if (extraFields != null) request.fields.addAll(extraFields);
    final streamed = await request.send().timeout(ApiConfig.timeout);
    final res = await http.Response.fromStream(streamed);
    return _handleResponse(res);
  }
}
