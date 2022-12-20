import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/subjects.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class CategoryScreen extends StatelessWidget {
  final ValueChanged<String> onSubjectSelected;

  const CategoryScreen({super.key, required this.onSubjectSelected});

  static const _subjectMeta = {
    'Computer Engineering':   {'emoji': '💻', 'color': Color(0xFF3B82F6)},
    'Mechanical Engineering': {'emoji': '⚙️', 'color': Color(0xFFF59E0B)},
    'Civil Engineering':      {'emoji': '🏗️', 'color': Color(0xFF10B981)},
    'Electrical Engineering': {'emoji': '⚡', 'color': Color(0xFFF59E0B)},
    'Electronics':            {'emoji': '🔌', 'color': Color(0xFF8B5CF6)},
    'Information Technology': {'emoji': '🌐', 'color': Color(0xFF06B6D4)},
  };

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDark;
    final bg      = isDark ? AppColors.darkBackground : AppColors.lightSecondaryBackground;
    final surface = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final border  = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPri = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text('Subjects'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Browse by Subject',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPri,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                'Tap a subject to filter notes',
                style: TextStyle(fontSize: 14, color: textSec),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final subject = subjects[i];
                  final meta    = _subjectMeta[subject] ?? {'emoji': '📚', 'color': const Color(0xFF3B82F6)};
                  final color   = meta['color'] as Color;

                  return _SubjectCard(
                    subject: subject,
                    emoji: meta['emoji'] as String,
                    color: color,
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    textPri: textPri,
                    textSec: textSec,
                    onTap: () => onSubjectSelected(subject),
                  );
                },
                childCount: subjects.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject;
  final String emoji;
  final Color color;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPri;
  final Color textSec;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.emoji,
    required this.color,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPri,
    required this.textSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const Spacer(),
            Text(
              subject,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'View notes',
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 12, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}