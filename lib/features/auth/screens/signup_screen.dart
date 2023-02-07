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
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
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
    {'value': 'admin',    'label': 'Ad.min',    'icon': Icons.admin_panel_settings_rounded},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name     = _nameCtrl.text.trim();
    final phone    = _phoneCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _loading = true);
    final provider = context.read<AuthProvider>();
    await provider.signup(
      email: email, 
      password: password, 
      roleInput: _role,
      displayName: name,
      phone: phone,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (provider.error == null && provider.user != null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final primary  = cs.primary;
    final isDark  = context.watch<ThemeProvider>().isDark;
    final bg      = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPri = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSec = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final border  = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final error   = context.watch<AuthProvider>().error;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ───────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/app_icon.png'),
                ),

                const SizedBox(height: 24),

                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textPri,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join the learning community',
                  style: TextStyle(fontSize: 14, color: textSec),
                ),

                const SizedBox(height: 32),

                // ── Role selector ──────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'I am a',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSec,
                    ),
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

                // ── Full Name ──────────────────────────────
                _Label(text: 'Full Name', isDark: isDark),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Phone ──────────────────────────────
                _Label(text: 'Phone (Optional)', isDark: isDark),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: '+1 234 567 890',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 28),

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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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

                const SizedBox(height: 24),
              ],
            ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        ),
      ),
    );
  }
}