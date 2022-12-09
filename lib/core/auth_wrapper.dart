import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/provider/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/home_screen.dart';
import 'navigation/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    if (provider.user != null) {
      return MainScreen();
    } else {
      return LoginScreen();
    }
  }
}