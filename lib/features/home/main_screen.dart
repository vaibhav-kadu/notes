import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/category/category_screen.dart';
import '../../features/notes/provider/notes_provider.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'package:notes/core/theme/app_colors.dart';
import 'package:notes/core/theme/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void _openNotesForSubject(String subject) {
    context.read<NotesProvider>().filterBySubject(subject);
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDark;
    final surface = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final border  = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const NotesScreen(),
          CategoryScreen(onSubjectSelected: _openNotesForSubject),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  outlineIcon: Icons.home_outlined,
                  label: 'Feed',
                  selected: _index == 0,
                  primary: primary,
                  isDark: isDark,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  outlineIcon: Icons.grid_view_outlined,
                  label: 'Subjects',
                  selected: _index == 1,
                  primary: primary,
                  isDark: isDark,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  outlineIcon: Icons.person_outline_rounded,
                  label: 'Profile',
                  selected: _index == 2,
                  primary: primary,
                  isDark: isDark,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final bool selected;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
    required this.selected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unselected = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? icon : outlineIcon,
              color: selected ? primary : unselected,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? primary : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}