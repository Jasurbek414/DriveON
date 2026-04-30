import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Android emulator localhost
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() => _storage.read(key: 'accessToken');
  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }
  static Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final res = await http.get(Uri.parse('$baseUrl$endpoint'), headers: await _headers());
    return _handleResponse(res);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl$endpoint'), headers: await _headers(), body: jsonEncode(body));
    return _handleResponse(res);
  }

  static Future<dynamic> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final res = await http.patch(Uri.parse('$baseUrl$endpoint'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    return _handleResponse(res);
  }

  static dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } else if (res.statusCode == 401) {
      clearTokens();
      throw Exception('Sessiya tugadi');
    } else {
      final err = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      throw Exception(err['message'] ?? 'Xatolik: ${res.statusCode}');
    }
  }

  // Auth
  static Future<Map<String, dynamic>> login(String username, String password) =>
      post('/api/auth/login', {'username': username, 'password': password});
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) =>
      post('/api/auth/register', data);

  // Users
  static Future<Map<String, dynamic>> getMe() => get('/api/users/me');

  // Orders
  static Future<Map<String, dynamic>> getOrders({int page = 0, int size = 20}) =>
      get('/api/orders?page=$page&size=$size');
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) =>
      post('/api/orders', data);
  static Future<Map<String, dynamic>> getDashboardStats() =>
      get('/api/orders/dashboard/stats');
}
