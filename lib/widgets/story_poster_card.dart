import 'package:flutter/material.dart';

import '../models/story.dart';
import '../theme/app_theme.dart';

class StoryPosterCard extends StatelessWidget {
  const StoryPosterCard({
    super.key,
    required this.story,
    required this.onTap,
    this.overlayColor,
  });

  final Story story;
  final VoidCallback onTap;
  final Color? overlayColor;

  Color _fallbackColor() {
    const palette = [
      Color(0xFF6B7A99),
      Color(0xFF8A5A5A),
      Color(0xFF5A8A6E),
      Color(0xFF7A6B99),
    ];
    return palette[story.title.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (story.coverPath != null)
                Image.network(
                  story.coverPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _fallbackColor()),
                )
              else
                Container(
                  color: _fallbackColor(),
                  alignment: Alignment.center,
                  child: Text(
                    story.title.isNotEmpty ? story.title[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.onPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (overlayColor != null)
                DecoratedBox(decoration: BoxDecoration(color: overlayColor)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color.fromARGB(193, 0, 0, 0)],
                    stops: [0.65, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    story.medium.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 12,
                child: Text(
                  story.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.onPrimary,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: story.progressFraction,
                  minHeight: 5,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
