import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.secondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
