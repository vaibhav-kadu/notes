import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService();

  User? user;
  bool isLoading = false;
  String? error;

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      user = await _service.login(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      user = await _service.signup(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}