import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../admin/admin_screen.dart';
import '../auth/provider/auth_provider.dart';
import '../notes/screens/notes_screen.dart';
import '../quiz/screens/quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App 🎓"),
        actions: [
          if (authProvider.role == "admin")
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminScreen(),
                  ),
                );
              },
            ),

          IconButton(
            onPressed: () async {
              await authProvider.logout();
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            icon: Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuizScreen()),
              );
            },
          )
        ],
      ),

      // 🔹 Main Content (Notes List)
      body: NotesScreen(),

      // 🔹 Floating Button (Future: Upload PDF)
      floatingActionButton: (authProvider.role == "teacher" &&
          authProvider.isVerified)
          ? FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload coming soon 🚀")),
          );
        },
        child: const Icon(Icons.upload),
      )
          : null,
    );
  }
}