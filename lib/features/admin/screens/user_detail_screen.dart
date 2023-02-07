import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../notes/models/note_model.dart';
import '../../notes/screens/pdf_view_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = false;
  late bool _isDeactivated;

  @override
  void initState() {
    super.initState();
    _isDeactivated = widget.user['is_deactivated'] == true;
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final posts = await context.read<AuthProvider>().fetchUserPosts(widget.user['id']);
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  Future<void> _toggleDeactivate() async {
    final newStatus = !_isDeactivated;
    try {
      await context.read<AuthProvider>().toggleUserStatus(widget.user['id'], newStatus);
      setState(() => _isDeactivated = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newStatus ? 'User Deactivated' : 'User Activated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDark;
    final textPri  = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final surface  = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightSecondaryBackground;
    final email    = widget.user['email'] ?? 'No email';
    final role     = widget.user['role'] ?? 'student';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text('User Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── User Header ─────────────────────
            Container(
              color: surface,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      email[0].toUpperCase(),
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.user['display_name'] ?? email, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPri)),
                  if (widget.user['display_name'] != null)
                    Text(email, style: TextStyle(fontSize: 14, color: textSec)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(role.toString().toUpperCase(), 
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                      if (widget.user['phone']?.toString().isNotEmpty ?? false) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.phone_outlined, size: 14, color: textSec),
                        const SizedBox(width: 4),
                        Text('${widget.user['phone']}', style: TextStyle(fontSize: 14, color: textSec)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleDeactivate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDeactivated ? Colors.green : Colors.red,
                      ),
                      child: Text(_isDeactivated ? 'Activate Account' : 'Deactivate Account'),
                    ),
                  ),
                ],
              ),
            ),

            // ── Posts Section ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Text('Uploaded Content', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPri)),
                  const Spacer(),
                  Text('${_posts.length} files', style: TextStyle(fontSize: 13, color: textSec)),
                ],
              ),
            ),

            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
            else if (_posts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No uploads found', style: TextStyle(color: textSec)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (context, i) {
                  final post = _posts[i];
                  final note = NoteModel.fromJson(post);
                  return ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(note.title, style: TextStyle(color: textPri)),
                    subtitle: Text(note.subject, style: TextStyle(color: textSec)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PdfViewScreen(title: note.title, url: note.fileUrl)),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
