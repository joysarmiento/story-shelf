import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SupabaseService.instance;

  late final _nameController = TextEditingController(
    text: _service.displayName,
  );
  late final _emailController = TextEditingController(text: _service.email);
  late final _usernameController = TextEditingController(
    text: _service.username,
  );
  late String? _avatarUrl = _service.avatarUrl;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    final controller = TextEditingController(text: _avatarUrl);
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Profile picture URL',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Use this'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null) return; // cancelled
    setState(() => _avatarUrl = url.isEmpty ? null : url);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final emailChanged = await _service.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        avatarUrl: _avatarUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailChanged
                ? 'Profile updated. Check your new email to confirm it.'
                : 'Profile updated',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppBackButton(),
                const SizedBox(height: AppTheme.spaceXxs),
                Text('Edit Profile', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spaceMd),
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(imageUrl: _avatarUrl, size: 120),
                      const SizedBox(height: AppTheme.spaceSm),
                      GestureDetector(
                        onTap: _pickPicture,
                        child: Text(
                          'Edit picture',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),

                _FieldLabel('Name'),
                const SizedBox(height: AppTheme.spaceSm),
                AppTextField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: AppTheme.spaceMd),

                _FieldLabel('Email'),
                const SizedBox(height: AppTheme.spaceSm),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter your email';
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                        ? null
                        : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: AppTheme.spaceMd),

                _FieldLabel('Username'),
                const SizedBox(height: AppTheme.spaceSm),
                AppTextField(
                  label: 'Username',
                  controller: _usernameController,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter a username';
                    return t.contains(RegExp(r'\s'))
                        ? 'No spaces allowed'
                        : null;
                  },
                ),
                const SizedBox(height: AppTheme.spaceSectionGap),

                PrimaryButton(
                  label: 'Update profile',
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary),
    );
  }
}
