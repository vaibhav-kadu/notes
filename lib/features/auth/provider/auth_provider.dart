import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService();

  User? user;
  bool isLoading = false;
  String? error;

  Future<void> signup(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _service.signUp(email, password);
      user = res.user;

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _service.login(email, password);
      user = res.user;

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    notifyListeners();
  }

  bool isLoggedIn() {
    return _service.getCurrentUser() != null;
  }
}