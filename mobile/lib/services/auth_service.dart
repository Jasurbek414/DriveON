import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthService() { initialize(); }

  Future<void> initialize() async {
    final token = await ApiService.getToken();
    if (token == null) { _isLoading = false; notifyListeners(); return; }
    try {
      _user = await ApiService.getMe();
      _isAuthenticated = true;
    } catch (_) {
      await ApiService.clearTokens();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _error = null; _isLoading = true; notifyListeners();
    try {
      final res = await ApiService.login(username, password);
      await ApiService.saveTokens(res['accessToken'], res['refreshToken']);
      _user = res['user'];
      _isAuthenticated = true;
      _isLoading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _error = null; _isLoading = true; notifyListeners();
    try {
      final res = await ApiService.register(data);
      await ApiService.saveTokens(res['accessToken'], res['refreshToken']);
      _user = res['user'];
      _isAuthenticated = true;
      _isLoading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearTokens();
    _user = null; _isAuthenticated = false; _error = null;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}
