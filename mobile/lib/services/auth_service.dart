import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;

  bool _isPinLocked = false;
  bool _hasPin = false;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPinLocked => _isPinLocked;
  bool get hasPin => _hasPin;

  AuthService() { initialize(); }

  Future<void> initialize() async {
    final token = await ApiService.getToken();
    if (token == null) { _isLoading = false; notifyListeners(); return; }
    try {
      _user = await ApiService.getMe();
      _isAuthenticated = true;
      final pin = await ApiService.getPin();
      _hasPin = pin != null;
      if (_hasPin) _isPinLocked = true;
    } catch (_) { await ApiService.clearTokens(); }
    _isLoading = false; notifyListeners();
  }

  void unlockPin() {
    _isPinLocked = false;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _error = null; _isLoading = true; notifyListeners();
    try {
      final res = await ApiService.login(phone, password);
      await ApiService.saveTokens(res['accessToken'], res['refreshToken']);
      _user = res['user']; _isAuthenticated = true;
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> registerByPhone(String phone, String password) async {
    _error = null; _isLoading = true; notifyListeners();
    try {
      final res = await ApiService.registerByPhone(phone, password);
      await ApiService.saveTokens(res['accessToken'], res['refreshToken']);
      _user = res['user']; _isAuthenticated = true;
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearTokens();
    await ApiService.clearPin();
    _user = null; 
    _isAuthenticated = false; 
    _error = null;
    _hasPin = false;
    _isPinLocked = false;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}
