import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import 'mood_picker.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({super.key, required this.memory, required this.onTap});

  final Memory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = formatLongDate(memory.dateCreated);
    final metaLabel = memory.progressReference != null
        ? '${memory.progressReference} · $dateLabel'
        : dateLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 72,
                child: memory.storyCoverPath != null
                    ? Image.network(
                        memory.storyCoverPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppTheme.primary.withValues(alpha: 0.6),
                        ),
                      )
                    : Container(color: AppTheme.primary.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          memory.storyTitle ??
                              memory.cleanTitle ??
                              'Untitled memory',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (memory.mood != null) ...[
                        const SizedBox(width: 8),
                        MoodBadge(mood: memory.mood!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    metaLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (memory.cleanTitle != null &&
                      memory.cleanTitle != memory.storyTitle)
                    Text(
                      memory.cleanTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (memory.quote != null)
                    Text(
                      '"${memory.quote}"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Text(
                      memory.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
