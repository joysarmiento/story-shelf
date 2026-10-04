import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.imageUrl, this.size = 120});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppTheme.secondary,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: size * 0.55, color: AppTheme.onPrimary),
    );
    return Semantics(
      image: true,
      label: 'Profile picture',
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: imageUrl == null
              ? fallback
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}
