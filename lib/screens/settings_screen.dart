import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'edit_profile_screen.dart';
import 'start_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _goToStart(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartScreen()),
      (_) => false,
    );
  }

  Future<void> _setContrast(BuildContext context, bool value) async {
    AppTheme.setHighContrast(value);
    try {
      await SupabaseService.instance.saveHighContrast(value);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Contrast changed, but couldn't be saved to your account.",
          ),
        ),
      );
    }
  }

  Future<void> _setTextSize(BuildContext context, TextSize value) async {
    AppTheme.setTextSize(value);
    try {
      await SupabaseService.instance.saveTextSize(value);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Text size changed, but couldn't be saved to your account.",
          ),
        ),
      );
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        content: Text(message, style: Theme.of(context).textTheme.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              textStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              foregroundColor: destructive ? AppTheme.error : AppTheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              textStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              foregroundColor: destructive ? AppTheme.error : AppTheme.primary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _signOut(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Sign out?',
      message: 'You can sign back in any time.',
      confirmLabel: 'Sign Out',
    );
    if (!ok || !context.mounted) return;
    try {
      await SupabaseService.instance.signOut();
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (context.mounted) _goToStart(context);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Delete account?',
      message:
          'This permanently deletes your account, stories and memories. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await SupabaseService.instance.deleteAccount();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete your account. Please try again.'),
        ),
      );
      return;
    }
    if (context.mounted) _goToStart(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppTheme.spaceXxs),
              Text('Settings', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppTheme.spaceMd),

              const _SectionLabel('Profile'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.person,
                    label: 'Edit Profile',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceLg),

              const _SectionLabel('Preference'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.contrast,
                    label: 'High Contrast',
                    trailing: Switch(
                      value: AppTheme.highContrast,
                      activeThumbColor: AppTheme.onPrimary,
                      activeTrackColor: AppTheme.onSurface,
                      inactiveThumbColor: AppTheme.onSurface,
                      inactiveTrackColor: AppTheme.surface,
                      trackOutlineColor: WidgetStatePropertyAll(
                        AppTheme.onSurface,
                      ),
                      onChanged: (value) => _setContrast(context, value),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: AppTheme.spaceMd,
                    endIndent: AppTheme.spaceMd,
                    color: AppTheme.secondary.withValues(alpha: 0.7),
                  ),
                  _TextSizeTile(
                    selected: AppTheme.textSize,
                    onChanged: (size) => _setTextSize(context, size),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceLg),

              const _SectionLabel('Account'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.logout,
                    label: 'Sign Out',
                    onTap: () => _signOut(context),
                  ),
                  Divider(
                    height: 1,
                    indent: AppTheme.spaceMd,
                    endIndent: AppTheme.spaceMd,
                    color: AppTheme.secondary.withValues(alpha: 0.7),
                  ),
                  _SettingsTile(
                    icon: Icons.person_remove,
                    label: 'Delete Account',
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMd,
          vertical: AppTheme.spaceMd,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.onSurface, size: 28),
            const SizedBox(width: AppTheme.spaceLg),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _TextSizeTile extends StatelessWidget {
  const _TextSizeTile({required this.selected, required this.onChanged});

  final TextSize selected;
  final ValueChanged<TextSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: AppTheme.onSurface, size: 28),
              const SizedBox(width: AppTheme.spaceLg),
              Expanded(
                child: Text(
                  'Text Size',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              for (final size in TextSize.values) ...[
                Expanded(
                  child: _SizePill(
                    label: size.label,
                    selected: size == selected,
                    onTap: () => onChanged(size),
                  ),
                ),
                if (size != TextSize.values.last)
                  const SizedBox(width: AppTheme.spaceSm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SizePill extends StatelessWidget {
  const _SizePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Text size $label',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.secondary,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? AppTheme.onPrimary : AppTheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
