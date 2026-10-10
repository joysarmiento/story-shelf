import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isUploadingPicture = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            if (_avatarUrl != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppTheme.error),
                title: Text(
                  'Remove picture',
                  style: TextStyle(color: AppTheme.error),
                ),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
          ],
        ),
      ),
    );

    switch (choice) {
      case 'gallery':
        await _uploadPicture();
      case 'remove':
        setState(() => _avatarUrl = null);
    }
  }

  Future<void> _uploadPicture() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingPicture = true);
      final url = await _service.uploadCoverImage(
        bytes: await picked.readAsBytes(),
        fileName: picked.name,
      );
      if (!mounted) return;
      setState(() => _avatarUrl = url);
    } catch (e) {
      debugPrint('Profile picture upload failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't upload that picture. Try again."),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPicture = false);
    }
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfileAvatar(imageUrl: _avatarUrl, size: 120),
                          if (_isUploadingPicture)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      GestureDetector(
                        onTap: _isUploadingPicture ? null : _pickPicture,
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
                  onPressed: _isUploadingPicture ? null : _handleSubmit,
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
