import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../theme/app_theme.dart';

class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Mood? selected;
  final ValueChanged<Mood?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spaceSm,
      runSpacing: AppTheme.spaceSm,
      children: [
        for (final mood in Mood.values)
          _MoodChoice(
            mood: mood,
            selected: mood == selected,
            onTap: () => onChanged(mood == selected ? null : mood),
          ),
      ],
    );
  }
}

class _MoodChoice extends StatelessWidget {
  const _MoodChoice({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: mood.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.secondary : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.onSurface : AppTheme.secondary,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                mood.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppTheme.onPrimary : AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoodBadge extends StatelessWidget {
  const MoodBadge({super.key, required this.mood});

  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Mood: ${mood.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.onSurface.withValues(alpha: 0.85),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              mood.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
