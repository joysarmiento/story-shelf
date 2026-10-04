// This is your app. It runs as it is: press run and you get the screen below.
//
// Nothing here is precious. Change the title, change the colors, delete the
// counter, add your own screens. It exists so that the repository is a working
// Flutter app from minute one instead of an empty folder.
//
// Everything in this file is Module 4 and 5 material: StatelessWidget,
// StatefulWidget, setState, Scaffold, AppBar, Column, Card, FilledButton.

// This replaces the template's lib/main.dart. It keeps the DevicePreview
// wrapper (per START-HERE.md) but swaps the counter demo for real app setup:
// Supabase initialization, the AppTheme, and StartScreen as the home.

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/start_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loads SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY from .env for local runs
  // (copy .env.example to .env first). For the GitHub Pages build, .env is
  // git-ignored, so the deploy workflow needs to pass the same two values a
  // different way instead — either write a .env file from repository
  // secrets as a build step, or switch these two lines to
  // String.fromEnvironment('SUPABASE_URL') / ...('SUPABASE_PUBLISHABLE_KEY')
  // and pass --dart-define at build time. Either works; pick one.
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  // Restore the saved contrast setting if someone is already signed in.
  SupabaseService.instance.applyPreferences();

  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Shelf',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        // Text size from Settings. Applied inside DevicePreview's own
        // MediaQuery so it isn't overridden by the preview toolbar.
        final scaled = Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(AppTheme.textSize.scale)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
        return DevicePreview.appBuilder(context, scaled);
      },
      theme: AppTheme.themeData,
      home: const StartScreen(),
    );
  }
}
