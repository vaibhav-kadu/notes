import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:notes/features/auth/provider/auth_provider.dart';
import 'package:notes/features/auth/screens/login_screen.dart';
import 'package:notes/core/navigation/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return provider.user != null ? const MainScreen() : const LoginScreen();
  }
}