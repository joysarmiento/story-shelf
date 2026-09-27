import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../widgets/story_form.dart';

class EditStoryScreen extends StatelessWidget {
  const EditStoryScreen({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: StoryForm(
        headingText: 'Edit Story',
        submitLabel: 'Save Story Edits',
        initialStory: story,
        onSubmit: (updated) async {
          // TODO: replace with SupabaseService.instance.updateStory(updated)
          // once the stories table exists.
          final index = sampleStories.indexWhere((s) => s.id == updated.id);
          if (index != -1) sampleStories[index] = updated;
          if (!context.mounted) return;
          Navigator.of(context).pop(updated);
        },
      ),
    );
  }
}
