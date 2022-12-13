import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  // ✅ Controllers (FIX 1)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ Role selection
  String selectedRole = "student";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Register 🚀")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Create Account 🚀",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 🔹 Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Role Dropdown (FIX 2: setState works now)
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
              items: ["student", "teacher", "admin"]
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // 🔹 Register Button
            ElevatedButton(
              onPressed: () async {
                await provider.signup(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  selectedRole,
                );

                if (!mounted) return;

                if (provider.user != null && provider.error == null) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Register"),
            ),

            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
