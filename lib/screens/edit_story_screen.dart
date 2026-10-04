import 'package:flutter/material.dart';

import '../models/story.dart';
import '../services/supabase_service.dart';
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
          try {
            await SupabaseService.instance.updateStory(updated);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not save changes: $e')),
            );
            return;
          }
          if (!context.mounted) return;
          Navigator.of(context).pop(updated);
        },
      ),
    );
  }
}
