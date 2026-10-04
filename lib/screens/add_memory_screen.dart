import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_form.dart';

class AddMemoryScreen extends StatelessWidget {
  const AddMemoryScreen({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: MemoryForm(
        headingText: 'Add Memory',
        submitLabel: 'Save Memory',
        story: story,
        onSubmit: (memory) async {
          // TODO: replace with SupabaseService.instance.addMemory(memory)
          // once the memories table is wired up.
          sampleMemories.insert(0, memory);
          if (!context.mounted) return;
          Navigator.of(context).pop(memory);
        },
      ),
    );
  }
}
