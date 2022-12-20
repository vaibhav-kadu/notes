import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/provider/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/home_screen.dart';
import 'navigation/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.user != null) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}