import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    required this.message,
    this.bordered = false,
    this.iconSize = 48,
    this.padding,
  }) : assert(
         icon != null || leading != null,
         'Provide either icon or leading.',
       );

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String message;
  final bool bordered;
  final double iconSize;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final visual =
        leading ??
        Icon(
          icon,
          size: iconSize,
          color: AppTheme.secondary.withValues(alpha: 0.6),
        );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        visual,
        SizedBox(height: leading != null ? AppTheme.spaceSm : AppTheme.spaceMd),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );

    final effectivePadding =
        padding ??
        (bordered
            ? const EdgeInsets.symmetric(
                vertical: AppTheme.spaceLg,
                horizontal: AppTheme.spaceMd,
              )
            : EdgeInsets.zero);

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      decoration: bordered
          ? BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            )
          : null,
      child: content,
    );
  }
}
