import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/provider/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text("Email: ${auth.user?.email ?? ''}"),
          Text("Role: ${auth.role ?? ''}"),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              await auth.logout();
            },
            child: Text("Logout"),
          )
        ],
      ),
    );
  }
}