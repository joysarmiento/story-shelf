import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.label = 'Back'});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      icon: const Icon(Icons.chevron_left, color: AppTheme.error),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.error),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
