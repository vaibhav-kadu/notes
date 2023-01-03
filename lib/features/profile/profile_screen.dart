import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../auth/provider/auth_provider.dart';
import '../notes/models/note_model.dart';
import '../notes/provider/notes_provider.dart';
import '../notes/screens/pdf_view_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDark;
    final auth     = context.watch<AuthProvider>();
    final notes    = context.watch<NotesProvider>();
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightSecondaryBackground;
    final surface  = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final border   = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPri  = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primary  = Theme.of(context).colorScheme.primary;

    final email = auth.user?.email ?? '';
    final role  = auth.role ?? 'student';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text(
          email.isNotEmpty ? email.split('@').first : 'Profile',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: textSec,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: textSec),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile header ───────────────────
            Container(
              color: surface,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        email.isNotEmpty
                            ? email[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _roleColor(role).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_roleEmoji(role)} ${role.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _roleColor(role),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        count: notes.uploadedNotes.length,
                        label: 'Uploads',
                        primary: primary,
                        textSec: textSec,
                        textPri: textPri,
                      ),
                      Container(width: 1, height: 40,
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                      _StatItem(
                        count: notes.bookmarkedNotes.length,
                        label: 'Bookmarks',
                        primary: primary,
                        textSec: textSec,
                        textPri: textPri,
                      ),
                      Container(width: 1, height: 40,
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                      _StatItem(
                        count: notes.likedNotes.length,
                        label: 'Liked',
                        primary: primary,
                        textSec: textSec,
                        textPri: textPri,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Notes sections ───────────────────
            _NotesSectionCard(
              title: '📤 Uploaded Notes',
              notes: notes.uploadedNotes,
              emptyText: 'You haven\'t uploaded any notes yet',
              isDark: isDark,
              surface: surface,
              border: border,
              textPri: textPri,
              textSec: textSec,
              primary: primary,
            ),

            const SizedBox(height: 8),

            _NotesSectionCard(
              title: '🔖 Bookmarked',
              notes: notes.bookmarkedNotes,
              emptyText: 'No bookmarks yet. Tap the bookmark icon on any note!',
              isDark: isDark,
              surface: surface,
              border: border,
              textPri: textPri,
              textSec: textSec,
              primary: primary,
            ),

            const SizedBox(height: 8),

            _NotesSectionCard(
              title: '❤️ Liked Notes',
              notes: notes.likedNotes,
              emptyText: 'No liked notes yet',
              isDark: isDark,
              surface: surface,
              border: border,
              textPri: textPri,
              textSec: textSec,
              primary: primary,
            ),

            if (role == 'admin') ...[
              const SizedBox(height: 8),
              _AdminUserSection(
                isDark: isDark,
                surface: surface,
                border: border,
                textPri: textPri,
                textSec: textSec,
                primary: primary,
              ),
            ],

            const SizedBox(height: 8),

            // ── Logout button ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  onPressed: () => auth.logout(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    isDark ? AppColors.darkError : AppColors.lightError,
                    side: BorderSide(
                      color: isDark ? AppColors.darkError : AppColors.lightError,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':   return const Color(0xFFF59E0B);
      case 'teacher': return const Color(0xFF10B981);
      default:        return const Color(0xFF3B82F6);
    }
  }

  String _roleEmoji(String role) {
    switch (role) {
      case 'admin':   return '👑';
      case 'teacher': return '👨‍🏫';
      default:        return '👨‍🎓';
    }
  }
}

class _AdminUserSection extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPri;
  final Color textSec;
  final Color primary;

  const _AdminUserSection({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPri,
    required this.textSec,
    required this.primary,
  });

  @override
  State<_AdminUserSection> createState() => _AdminUserSectionState();
}

class _AdminUserSectionState extends State<_AdminUserSection> {
  bool _expanded = false;
  List<Map<String, dynamic>> _users = [];
  bool _loading = false;

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await context.read<AuthProvider>().fetchAllUsers();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.surface,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (_expanded && _users.isEmpty) _loadUsers();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    '👥 User Management',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.textPri,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.textSec,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: widget.border, indent: 16, endIndent: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
            else if (_users.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No users found in database',
                    style: TextStyle(fontSize: 13, color: widget.textSec)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: widget.border, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final user = _users[i];
                  final email = user['email'] ?? 'No email';
                  final role = user['role'] ?? 'student';
                  final id = user['id'];

                  return ListTile(
                    title: Text(email,
                        style: TextStyle(fontSize: 14, color: widget.textPri)),
                    subtitle: Text(role.toString().toUpperCase(),
                        style: TextStyle(fontSize: 12, color: widget.textSec)),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove_rounded, color: Colors.red, size: 20),
                      onPressed: () => _confirmDeleteUser(id, email),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteUser(String userId, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Delete account for $email? This will only remove them from the public directory. Internal auth deletion requires manual dashboard action.'),
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

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color primary;
  final Color textSec;
  final Color textPri;
  const _StatItem({
    required this.count,
    required this.label,
    required this.primary,
    required this.textSec,
    required this.textPri,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textPri,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: textSec)),
      ],
    );
  }
}

class _NotesSectionCard extends StatefulWidget {
  final String title;
  final List<NoteModel> notes;
  final String emptyText;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPri;
  final Color textSec;
  final Color primary;

  const _NotesSectionCard({
    required this.title,
    required this.notes,
    required this.emptyText,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPri,
    required this.textSec,
    required this.primary,
  });

  @override
  State<_NotesSectionCard> createState() => _NotesSectionCardState();
}

class _NotesSectionCardState extends State<_NotesSectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.surface,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.textPri,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.notes.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.textSec,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_expanded) ...[
            Divider(
              height: 1,
              color: widget.border,
              indent: 16,
              endIndent: 16,
            ),
            if (widget.notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Text(
                  widget.emptyText,
                  style: TextStyle(fontSize: 13, color: widget.textSec),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.notes.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: widget.border,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final note = widget.notes[i];
                  return ListTile(
                    onTap: () {
                      context.read<NotesProvider>().incrementView(note);
                      if (note.type == 'notes' || note.fileUrl.toLowerCase().endsWith('.pdf')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewScreen(
                              title: note.title,
                              url: note.fileUrl,
                            ),
                          ),
                        );
                      } else {
                        // Generic open fallback
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        note.type == 'mcq_test'
                            ? Icons.quiz_rounded
                            : Icons.picture_as_pdf_rounded,
                        size: 20,
                        color: widget.primary,
                      ),
                    ),
                    title: Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.textPri,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      note.subject,
                      style: TextStyle(fontSize: 12, color: widget.textSec),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: widget.textSec,
                      size: 18,
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}