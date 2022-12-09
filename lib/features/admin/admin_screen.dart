import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final supabase = Supabase.instance.client;

  List users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final res = await supabase
        .from('users')
        .select()
        .eq('role', 'teacher');

    setState(() {
      users = res;
    });
  }

  Future<void> verifyUser(String id) async {
    await supabase
        .from('users')
        .update({'is_verified': true})
        .eq('id', id);

    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return ListTile(
            title: Text(user['email']),
            subtitle: Text(
                user['is_verified'] ? "Verified" : "Pending"),
            trailing: user['is_verified']
                ? const Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
              onPressed: () => verifyUser(user['id']),
              child: const Text("Approve"),
            ),
          );
        },
      ),
    );
  }
}