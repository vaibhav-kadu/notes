import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/note_model.dart';
import '../provider/notes_provider.dart';
import '../../../core/constants/subjects.dart';
import 'pdf_view_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchCtrl = TextEditingController();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<NotesProvider>().loadNotes(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Upload dialog ─────────────────────────────────
  Future<void> _pickAndUpload(BuildContext context) async {
    final notesProvider = context.read<NotesProvider>();
    final authProvider  = context.read<AuthProvider>();

    if (!authProvider.canUploadNotes) {
      _showSnack(context, 'Only teachers and admins can upload notes.', isError: true);
      return;
    }

    String title         = '';
    String selectedSub   = subjects.first;
    String selectedType  = 'notes';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UploadBottomSheet(
        onConfirm: (t, s, ty) {
          title        = t;
          selectedSub  = s;
          selectedType = ty;
        },
      ),
    );

    if (confirmed != true || title.isEmpty) return;

    final result = await FilePicker.pickFiles(
      type: FileType.any,
    );

    if (result == null) return;

    try {
      final file = File(result.files.single.path!);
      await notesProvider.uploadNoteSecure(title, selectedSub, selectedType, file);
      if (context.mounted) {
        _showSnack(context, 'Uploaded successfully! ✅');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnack(context, e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  void _showSnack(BuildContext ctx, String msg, {bool isError = false}) {
    final isDark = ctx.read<ThemeProvider>().isDark;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? (isDark ? AppColors.darkError : AppColors.lightError)
            : (isDark ? AppColors.darkSuccess : AppColors.lightSuccess),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openNote(NoteModel note) async {
    final trimmed = note.fileUrl.trim();
    if (trimmed.isEmpty) return;

    // Increment view count
    context.read<NotesProvider>().incrementView(note);

    final isPdf = trimmed.toLowerCase().contains('.pdf') || 
                  trimmed.toLowerCase().contains('?alt=media') && note.title.toLowerCase().endsWith('.pdf');

    if (isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewScreen(title: note.title, url: trimmed),
        ),
      );
    } else {
      // For images, docx, videos, etc. open in external app
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            _showSnack(context, 'No app found to open this file type.', isError: true);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = context.watch<ThemeProvider>().isDark;
    final provider      = context.watch<NotesProvider>();
    final authProvider  = context.watch<AuthProvider>();
    final bg            = isDark ? AppColors.darkBackground : AppColors.lightSecondaryBackground;
    final surface       = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final border        = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSec       = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return PopScope(
      canPop: _searchCtrl.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_searchCtrl.text.isNotEmpty) {
          _searchCtrl.clear();
          provider.searchNotes('');
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        body: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: surface,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset('assets/app_icon.png'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                ),
                if (authProvider.role == 'admin')
                  IconButton(
                    icon: Icon(Icons.admin_panel_settings_rounded, color: textSec),
                    onPressed: () {}, // navigate to admin
                  ),
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: textSec),
                  onPressed: () => authProvider.logout(),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  color: surface,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: provider.searchNotes,
                    onTap: () => setState(() => _searchFocused = true),
                    onEditingComplete: () => setState(() => _searchFocused = false),
                    decoration: InputDecoration(
                      hintText: 'Search notes, subjects...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.searchNotes('');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightSecondaryBackground,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.filteredNotes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64,
                          color: isDark ? AppColors.darkDisabledText : AppColors.lightDisabledText),
                      const SizedBox(height: 16),
                      Text('No notes found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          )),
                      const SizedBox(height: 8),
                      Text('Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkDisabledText : AppColors.lightDisabledText,
                          )),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          '${provider.filteredNotes.length} Notes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textSec,
                          ),
                        ),
                      );
                    }
                    final note = provider.filteredNotes[i - 1];
                    return _NoteCard(
                      note: note,
                      isDark: isDark,
                      onTap: () => _openNote(note),
                      onBookmark: () => provider.toggleBookmark(note),
                      onLike: () => provider.toggleLike(note),
                      onDelete: authProvider.role == 'admin' ? () => _confirmDelete(context, note) : null,
                    );
                  },
                  childCount: provider.filteredNotes.length + 1,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        floatingActionButton: authProvider.canManageNotes
            ? FloatingActionButton(
          onPressed: () => _pickAndUpload(context),
          child: const Icon(Icons.add_rounded),
        )
            : null,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text('Are you sure you want to delete "${note.title}"? This action cannot be undone.'),
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
      try {
        await context.read<NotesProvider>().deleteNote(note.id);
        if (mounted) _showSnack(context, 'Note deleted successfully');
      } catch (e) {
        if (mounted) _showSnack(context, 'Failed to delete note', isError: true);
      }
    }
  }
}

// ─── Note Card (Instagram-style) ─────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onLike;
  final VoidCallback? onDelete; // Added for admin

  const _NoteCard({
    required this.note,
    required this.isDark,
    required this.onTap,
    required this.onBookmark,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final surface  = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final border   = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPri  = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primary  = Theme.of(context).colorScheme.primary;
    final isTest   = note.type == 'mcq_test';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail / Header ──────────────────
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: note.thumbnailUrl.trim().isNotEmpty
                      ? Image.network(
                    note.thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ThumbnailPlaceholder(isTest: isTest),
                  )
                      : _ThumbnailPlaceholder(isTest: isTest),
                ),
                // Type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isTest ? Colors.orange : primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isTest ? '📝 MCQ Test' : '📄 Notes',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Delete button for admin
                if (onDelete != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.subject,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  note.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPri,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // uploaderEmail removed because it's missing in your DB
              ],
            ),
          ),

          // ── Action row ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                // Like - label count removed as it's missing in DB
                _ActionBtn(
                  icon: note.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: 'Like',
                  color: note.isLiked ? Colors.red : textSec,
                  onTap: onLike,
                ),
                // Bookmark
                _ActionBtn(
                  icon: note.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: note.isBookmarked ? primary : textSec,
                  onTap: onBookmark,
                ),
                const Spacer(),
                // Views
                Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: textSec),
                    const SizedBox(width: 4),
                    Text(
                      '${note.views}',
                      style: TextStyle(fontSize: 12, color: textSec),
                    ),
                  ],
                ),
                // Open
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  final bool isTest;
  const _ThumbnailPlaceholder({required this.isTest});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: isTest ? Colors.orange.withValues(alpha: 0.08) : Colors.blue.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTest ? Icons.quiz_rounded : Icons.picture_as_pdf_rounded,
            size: 52,
            color: isTest ? Colors.orange : Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            isTest ? 'MCQ Test' : 'PDF Note',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isTest ? Colors.orange : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return IconButton(
        icon: Icon(icon, size: 22, color: color),
        onPressed: onTap,
        splashRadius: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Upload Bottom Sheet ──────────────────────────────────────────────────────
class _UploadBottomSheet extends StatefulWidget {
  final void Function(String title, String subject, String type) onConfirm;
  const _UploadBottomSheet({required this.onConfirm});

  @override
  State<_UploadBottomSheet> createState() => _UploadBottomSheetState();
}

class _UploadBottomSheetState extends State<_UploadBottomSheet> {
  final _titleCtrl = TextEditingController();
  String _subject  = subjects.first;
  String _type     = 'notes';

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.read<ThemeProvider>().isDark;
    final surface = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final textPri = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Upload File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 20),

          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(
              labelText: 'Subject',
              prefixIcon: Icon(Icons.category_rounded, size: 20),
            ),
            items: subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _subject = v!),
          ),
          const SizedBox(height: 14),

          // Type selector
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  label: '📄 Notes',
                  selected: _type == 'notes',
                  onTap: () => setState(() => _type = 'notes'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeChip(
                  label: '📝 MCQ Test',
                  selected: _type == 'mcq_test',
                  onTap: () => setState(() => _type = 'mcq_test'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleCtrl.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a title')),
                      );
                      return;
                    }
                    widget.onConfirm(title, _subject, _type);
                    Navigator.pop(context, true);
                  },
                  child: const Text('Pick File'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark  = context.read<ThemeProvider>().isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? primary : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
            ),
          ),
        ),
      ),
    );
  }
}