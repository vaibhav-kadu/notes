import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService();

  User? user;
  bool isLoading = false;
  String? error;

  // 🔹 Check existing session (Auto Login)
  void checkSession() {
    user = _service.getCurrentUser();
    notifyListeners();
  }

  // 🔹 Signup
  Future<void> signup(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final res = await _service.signUp(email, password);

      if (res.user != null) {
        user = res.user;
      }
    } on AuthException catch (e) {
      error = e.message;
    } catch (e) {
      error = "Something went wrong";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Login
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final res = await _service.login(email, password);

      if (res.user != null) {
        user = res.user;
      }
    } on AuthException catch (e) {
      error = e.message;
    } catch (e) {
      error = "Login failed";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    try {
      await _service.logout();
      user = null;
    } catch (e) {
      error = "Logout failed";
    }
    notifyListeners();
  }

  // 🔹 Check login state
  bool isLoggedIn() {
    return user != null;
  }

  Future<void> loadNotes() async {
    isLoading = true;
    notifyListeners();

    notes = await _service.fetchMixedFeed();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadFeed() async {
    isLoading = true;
    notifyListeners();

    notes = await _service.fetchMixedFeed();

    isLoading = false;
    notifyListeners();
  }
}