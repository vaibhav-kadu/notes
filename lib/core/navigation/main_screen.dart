import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../features/auth/provider/auth_provider.dart';
import '../../features/admin/screens/users_screen.dart';
import '../../features/category/category_screen.dart';
import '../../features/notes/provider/notes_provider.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<int> _history = [0];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _history.add(index);
    });
  }

  void _openNotesForSubject(String subject) {
    context.read<NotesProvider>().filterBySubject(subject);

    setState(() {
      _currentIndex = 0;
      _history.add(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.role == 'admin';

    final List<Widget> screens = [
      const NotesScreen(),
      CategoryScreen(onSubjectSelected: _openNotesForSubject),
      if (isAdmin) const UsersScreen(),
      const ProfileScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Feed"),
      const BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: "Category"),
      if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "Users"),
      const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_history.length > 1) {
          setState(() {
            _history.removeLast();
            _currentIndex = _history.last;
            if (_currentIndex >= screens.length) {
              _currentIndex = 0;
            }
          });
        } else {
          if (_currentIndex == 0) {
            SystemNavigator.pop();
          } else {
            setState(() {
              _currentIndex = 0;
              _history.add(0);
            });
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}
