import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/provider/auth_provider.dart';
import '../notes/screens/notes_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App 🎓"),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // 🔹 Main Content (Notes List)
      body: NotesScreen(),

      // 🔹 Floating Button (Future: Upload PDF)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Next module: Upload PDF
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload feature coming next 🚀")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}