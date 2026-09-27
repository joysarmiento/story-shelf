import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'docs/assets/images/logo.png',
                width: 170,
                height: 170,
              ),
              const SizedBox(height: AppTheme.spaceXxs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Image.asset(
                  'docs/assets/images/story-shelf-wordmark.png',
                  width: 250,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXxs),
              Text(
                'Your stories. Your memories.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(flex: 5),
              PrimaryButton(
                label: 'Get started',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
