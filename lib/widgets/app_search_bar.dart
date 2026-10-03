import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = controller.text.isNotEmpty;

    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Semantics(
      label: hint,
      textField: true,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyMedium,
        cursorColor: AppTheme.secondary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.secondary.withValues(alpha: 0.9),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 13,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close, color: AppTheme.secondary),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : const Icon(Icons.search, color: AppTheme.secondary),
          enabledBorder: border(AppTheme.secondary, 2),
          focusedBorder: border(AppTheme.onSurface, 2),
          border: border(AppTheme.secondary, 2),
        ),
      ),
    );
  }
}
