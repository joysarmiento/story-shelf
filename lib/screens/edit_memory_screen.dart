import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_form.dart';

class EditMemoryScreen extends StatelessWidget {
  const EditMemoryScreen({super.key, required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final story = sampleStories.cast<Story?>().firstWhere(
      (s) => s!.id == memory.storyId,
      orElse: () => null,
    );
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: MemoryForm(
        headingText: 'Edit Memory',
        submitLabel: 'Save Memory Edits',
        story: story,
        storyTitle: memory.storyTitle,
        initialMemory: memory,
        onSubmit: (updated) async {
          // TODO: replace with SupabaseService.instance.updateMemory(updated)
          final index = sampleMemories.indexWhere((m) => m.id == updated.id);
          if (index != -1) sampleMemories[index] = updated;
          if (!context.mounted) return;
          Navigator.of(context).pop(updated);
        },
      ),
    );
  }
}
