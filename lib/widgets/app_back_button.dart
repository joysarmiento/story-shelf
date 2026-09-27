import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.label = 'Back'});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      icon: const Icon(Icons.chevron_left, color: AppTheme.error),
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          color: AppTheme.error,
          fontWeight: FontWeight.w600, // semibold
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
