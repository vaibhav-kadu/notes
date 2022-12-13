import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/category/category_screen.dart';
import '../../features/notes/provider/notes_provider.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  void _openNotesForSubject(String subject) {
    Provider.of<NotesProvider>(context, listen: false).filterBySubject(subject);

    setState(() {
      index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          NotesScreen(),
          CategoryScreen(onSubjectSelected: _openNotesForSubject),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Category"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
