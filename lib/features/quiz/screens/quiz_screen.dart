import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../provider/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _started = false;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void dispose() {
    context.read<QuizProvider>().resetQuiz();
    super.dispose();
  }

  void _handleAnswer(QuizProvider provider, int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      provider.answer(index);
      setState(() {
        _selectedAnswer = null;
        _answered = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDark;
    final provider = context.watch<QuizProvider>();
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightSecondaryBackground;
    final surface  = isDark ? AppColors.darkSecondaryBackground : AppColors.lightBackground;
    final textPri  = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec  = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final primary  = Theme.of(context).colorScheme.primary;

    if (!_started) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: surface,
          title: const Text('Quiz'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.darkPrimaryGradient
                        : AppColors.lightPrimaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                Text('Engineering Quiz',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPri)),
                const SizedBox(height: 8),
                Text('Test your knowledge with ${provider.questions.length} questions',
                    style: TextStyle(color: textSec, fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _InfoChip(icon: Icons.timer_rounded, label: '30s per question', isDark: isDark),
                    const SizedBox(width: 10),
                    _InfoChip(icon: Icons.stars_rounded, label: '${provider.questions.length} pts max', isDark: isDark),
                  ],
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Quiz'),
                    onPressed: () {
                      setState(() => _started = true);
                      provider.startTimer();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isFinished = provider.isFinished;

    if (isFinished) {
      final pct = provider.questions.isEmpty
          ? 0.0
          : provider.score / provider.questions.length;

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(backgroundColor: surface, title: const Text('Quiz Result')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pct >= 0.7 ? '🎉' : '📚', style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  pct >= 0.7 ? 'Great Job!' : 'Keep Practicing!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPri),
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored ${provider.score} out of ${provider.questions.length}',
                  style: TextStyle(fontSize: 16, color: textSec),
                ),
                const SizedBox(height: 24),
                // Score circle
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.1),
                    border: Border.all(color: primary, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(pct * 100).round()}%',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primary),
                        ),
                        Text('score', style: TextStyle(fontSize: 11, color: textSec)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Try Again'),
                    onPressed: () {
                      provider.resetQuiz();
                      provider.startTimer();
                      setState(() { _started = true; _selectedAnswer = null; _answered = false; });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Notes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = provider.questions[provider.currentIndex];
    final progress = (provider.currentIndex + 1) / provider.questions.length;
    final timeLeft = provider.timeLeft;
    final timeColor = timeLeft <= 10 ? Colors.red : primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text('Q ${provider.currentIndex + 1}/${provider.questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, size: 16, color: primary),
                const SizedBox(width: 4),
                Text(
                  '${provider.score}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: timeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: timeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded, size: 16, color: timeColor),
                      const SizedBox(width: 6),
                      Text(
                        '$timeLeft s',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: timeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Text(
                question.question,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Choose an answer:',
              style: TextStyle(fontSize: 13, color: textSec, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            // Options
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final isSelected = _selectedAnswer == i;
                  final isCorrect  = question.correctIndex == i;
                  Color borderColor;
                  Color bgColor;
                  Color textColor = textPri;

                  if (_answered && isSelected) {
                    if (isCorrect) {
                      borderColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
                      bgColor     = borderColor.withValues(alpha: 0.1);
                      textColor   = borderColor;
                    } else {
                      borderColor = isDark ? AppColors.darkError : AppColors.lightError;
                      bgColor     = borderColor.withValues(alpha: 0.1);
                      textColor   = borderColor;
                    }
                  } else {
                    borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                    bgColor     = surface;
                  }

                  return GestureDetector(
                    onTap: () => _handleAnswer(provider, i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? borderColor : primary.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              question.options[i],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_answered && isSelected)
                            Icon(
                              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: borderColor,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textSec = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final border  = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textSec),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: textSec)),
        ],
      ),
    );
  }
}