import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await SupabaseService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not log in: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spaceSectionGap),
                Image.asset(
                  'docs/assets/images/logo.png',
                  width: 140,
                  height: 140,
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text('Welcome Back ♡', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'Your stories are waiting for you.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSectionGap),
                AppTextField(
                  label: 'Email / Username',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email or username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceListGap),
                AppTextField(
                  label: 'Password',
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppTheme.onSurface,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.montserrat(
                        color: AppTheme.onSurface,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600, // semibold
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                PrimaryButton(
                  label: 'Open My Shelf',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    // added for easier viewing of changes during development, will remove this in production
                    child: const Text(
                      'Skip login (dev)',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spaceLg),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: const [
                          TextSpan(text: "New to Story Shelf? "),
                          TextSpan(
                            text: 'Sign up.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
