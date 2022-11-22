import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            AuthTextField(controller: emailController, hint: "Email"),
            SizedBox(height: 10),
            AuthTextField(
              controller: passController,
              hint: "Password",
              obscure: true,
            ),
            SizedBox(height: 20),

            if (provider.isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  provider.login(
                    emailController.text,
                    passController.text,
                  );
                },
                child: Text("Login"),
              ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                );
              },
              child: Text("Create Account"),
            ),

            if (provider.error != null)
              Text(provider.error!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}