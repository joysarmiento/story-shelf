import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/app_back_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await SupabaseService.instance.resetPasswordForEmail(
        _emailController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your email for a reset link.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send reset link: $e')));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spaceMd),
                const AppBackButton(),
                const SizedBox(height: AppTheme.spaceMd),
                Center(
                  child: Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Center(
                  child: Text(
                    'Enter your email so we can send you the password reset link',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSectionGap),
                Text(
                  'Email',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                AppTextField(
                  label: 'Email',
                  hint: 'e.g. yourname@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email';
                    }
                    if (!_emailPattern.hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceSectionGap),
                PrimaryButton(
                  label: 'Send Code',
                  isLoading: _isLoading,
                  onPressed: _handleSendCode,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: const [
                          TextSpan(text: 'Already Registered? '),
                          TextSpan(
                            text: 'Log in.',
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
