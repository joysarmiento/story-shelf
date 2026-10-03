import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded, outlined search field from the Search mockup. Used by Library
/// and Memories. The parent owns the [controller] and rebuilds on
/// [onChanged], which also refreshes the search / clear icon.
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
        cursorColor: AppTheme.onSurface,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurface.withValues(alpha: 0.6),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 13,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close, color: AppTheme.onSurface),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : const Icon(Icons.search, color: AppTheme.onSurface),
          enabledBorder: border(AppTheme.onSurface, 2),
          focusedBorder: border(AppTheme.error, 2),
          border: border(AppTheme.onSurface, 2),
        ),
      ),
    );
  }
}
