import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home, label: 'Home'),
    (icon: Icons.menu_book, label: 'Library'),
    (icon: Icons.search, label: 'Search'),
    (icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.onSurface.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _items[i].icon,
                              color: i == currentIndex
                                  ? AppTheme.error
                                  : AppTheme.onPrimary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _items[i].label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: i == currentIndex
                                    ? AppTheme.error
                                    : AppTheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
