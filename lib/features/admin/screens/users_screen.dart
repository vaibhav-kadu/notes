import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadUsers());
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final users = await context.read<AuthProvider>().fetchAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDark;
    final textPri  = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final surface  = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final border   = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightSecondaryBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: textSec),
            const SizedBox(height: 16),
            Text(
              'No users found in database',
              style: TextStyle(fontSize: 16, color: textSec, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Users will appear here as they log in and sync their profiles.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textSec),
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = _users[index];
          final email = user['email'] ?? 'No email';
          final role = user['role'] ?? 'student';
          final postCount = user['post_count'] ?? 0;
          final reportCount = user['report_count'] ?? 0;
          final isDeactivated = user['is_deactivated'] == true;

          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDeactivated ? Colors.red.withValues(alpha: 0.5) : border,
                width: isDeactivated ? 2 : 1,
              ),
            ),
            child: ListTile(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => UserDetailScreen(user: user))
              ).then((_) => _loadUsers()),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  (user['display_name']?.toString().isNotEmpty ?? false)
                      ? user['display_name']![0].toUpperCase()
                      : email[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      (user['display_name']?.toString().isNotEmpty ?? false)
                          ? user['display_name']
                          : email,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDeactivated ? Colors.red : textPri,
                        decoration: isDeactivated ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (isDeactivated)
                    const Text(' (DEACTIVATED)', 
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user['display_name']?.toString().isNotEmpty ?? false)
                    Text(email, style: TextStyle(fontSize: 12, color: textSec)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        role.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _roleColor(role.toString()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.description_outlined, size: 12, color: textSec),
                      const SizedBox(width: 4),
                      Text('$postCount', style: TextStyle(fontSize: 11, color: textSec)),
                      if (user['phone']?.toString().isNotEmpty ?? false) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.phone_outlined, size: 12, color: textSec),
                        const SizedBox(width: 4),
                        Text('${user['phone']}', style: TextStyle(fontSize: 11, color: textSec)),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':   return const Color(0xFFF59E0B);
      case 'teacher': return const Color(0xFF10B981);
      default:        return const Color(0xFF3B82F6);
    }
  }

  Future<void> _confirmDeleteUser(String userId, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Delete account for $email? This action only removes their profile from the app list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().deleteUser(userId);
      _loadUsers();
    }
  }
}
