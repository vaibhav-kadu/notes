import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../provider/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  String _role        = 'student';
  bool _obscure       = true;
  bool _obscureC      = true;
  bool _loading       = false;

  static const _roles = [
    {'value': 'student',  'label': 'Student',  'icon': Icons.school_rounded},
    {'value': 'teacher',  'label': 'Teacher',  'icon': Icons.cast_for_education_rounded},
    {'value': 'admin',    'label': 'Admin',    'icon': Icons.admin_panel_settings_rounded},
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) return;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);
    final provider = context.read<AuthProvider>();
    await provider.signup(email, password, _role);
    if (!mounted) return;
    setState(() => _loading = false);

    if (provider.error == null && provider.user != null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDark;
    final cs      = Theme.of(context).colorScheme;
    final bg      = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPri = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final border  = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final error   = context.watch<AuthProvider>().error;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Notes 🚀',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start your learning journey today',
                style: TextStyle(fontSize: 14, color: textSec),
              ),

              const SizedBox(height: 32),

              // ── Role selector ──────────────────────
              Text(
                'I am a',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSec,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: _roles.map((r) {
                  final selected = _role == r['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = r['value'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primary.withValues(alpha: 0.1)
                              : (isDark
                              ? AppColors.darkSecondaryBackground
                              : AppColors.lightSecondaryBackground),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? cs.primary : border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              r['icon'] as IconData,
                              size: 24,
                              color: selected ? cs.primary : textSec,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? cs.primary : textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Email ──────────────────────────────
              _Label(text: 'Email', isDark: isDark),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
              ),

              const SizedBox(height: 16),

              // ── Password ───────────────────────────
              _Label(text: 'Password', isDark: isDark),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Min. 8 characters',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Confirm Password ───────────────────
              _Label(text: 'Confirm Password', isDark: isDark),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureC,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signup(),
                decoration: InputDecoration(
                  hintText: 'Re-enter password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureC ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureC = !_obscureC),
                  ),
                ),
              ),

              // ── Error ──────────────────────────────
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkError : AppColors.lightError)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16,
                          color: isDark ? AppColors.darkError : AppColors.lightError),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkError : AppColors.lightError,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Submit ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  child: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Create Account'),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: textSec, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
      ),
    );
  }
}