import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/memories_screen.dart';

class AppTab {
  AppTab._();

  static const home = 0;
  static const library = 1;
  static const memories = 2;
  static const profile = 3;
}

void navigateToTab(
  BuildContext context,
  int index, {
  required int currentIndex,
}) {
  if (index == currentIndex) return;

  final Widget? screen = switch (index) {
    AppTab.home => const HomeScreen(),
    AppTab.library => const LibraryScreen(),
    AppTab.memories => const MemoriesScreen(),

    _ => null,
  };

  if (screen == null) {
    // Profile screen doesn't exist yet.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
    return;
  }

  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
}
