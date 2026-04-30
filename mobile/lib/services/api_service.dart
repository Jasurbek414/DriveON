import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://drive-api.ecos.uz';

  static Future<File> _getTokenFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/auth_tokens.json');
  }

  static Future<String?> getToken() async {
    try {
      final file = await _getTokenFile();
      if (!await file.exists()) return null;
      final data = jsonDecode(await file.readAsString());
      return data['accessToken'];
    } catch (_) { return null; }
  }

  static Future<void> saveTokens(String access, String refresh) async {
    final file = await _getTokenFile();
    await file.writeAsString(jsonEncode({'accessToken': access, 'refreshToken': refresh}));
  }

  static Future<void> clearTokens() async {
    final file = await _getTokenFile();
    if (await file.exists()) await file.delete();
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('appPin');
  }
  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appPin', pin);
  }
  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('appPin');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  static Future<dynamic> get(String ep) async {
    final r = await http.get(Uri.parse('$baseUrl$ep'), headers: await _headers());
    return _handle(r);
  }

  static Future<dynamic> post(String ep, Map<String, dynamic> body) async {
    final r = await http.post(Uri.parse('$baseUrl$ep'), headers: await _headers(), body: jsonEncode(body));
    return _handle(r);
  }

  static Future<dynamic> patch(String ep, [Map<String, dynamic>? body]) async {
    final r = await http.patch(Uri.parse('$baseUrl$ep'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    return _handle(r);
  }

  static Future<dynamic> delete(String ep) async {
    final r = await http.delete(Uri.parse('$baseUrl$ep'), headers: await _headers());
    return _handle(r);
  }

  static dynamic _handle(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return r.body.isNotEmpty ? jsonDecode(r.body) : null;
    if (r.statusCode == 401) { clearTokens(); throw Exception('Sessiya tugadi'); }
    final err = r.body.isNotEmpty ? jsonDecode(r.body) : {};
    throw Exception(err['message'] ?? 'Xatolik: ${r.statusCode}');
  }

  // Auth
  static Future<dynamic> sendOtp(String phone) => post('/api/auth/otp/send', {'phoneNumber': phone});
  static Future<dynamic> verifyOtp(String phone, String code) => post('/api/auth/otp/verify', {'phoneNumber': phone, 'code': code});
  static Future<dynamic> checkPhone(String phone) => get('/api/auth/check-phone?phone=$phone');
  static Future<dynamic> login(String username, String password) => post('/api/auth/login', {'username': username, 'password': password});
  static Future<dynamic> registerByPhone(String phone, String password) => post('/api/auth/register/phone', {'phoneNumber': phone, 'password': password});
  static Future<dynamic> getMe() => get('/api/users/me');

  // Vehicles
  static Future<dynamic> getVehicles() => get('/api/vehicles');
  static Future<dynamic> addVehicle(Map<String, dynamic> data) => post('/api/vehicles', data);
  static Future<dynamic> deleteVehicle(int id) => delete('/api/vehicles/$id');

  // Fines
  static Future<dynamic> getFines() => get('/api/fines');
  static Future<dynamic> getUnpaidFines() => get('/api/fines/unpaid');
  static Future<dynamic> getUnpaidCount() => get('/api/fines/count');

  // Cards & Payments
  static Future<dynamic> getCards() => get('/api/payments/cards');
  static Future<dynamic> addCard(Map<String, dynamic> data) => post('/api/payments/cards', data);
  static Future<dynamic> deleteCard(int id) => delete('/api/payments/cards/$id');
  static Future<dynamic> payFine(int fineId, int cardId) => post('/api/payments/fine/$fineId?cardId=$cardId', {});
  static Future<dynamic> getPaymentHistory() => get('/api/payments/history');
}
