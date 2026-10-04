import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/story_form.dart';
import 'story_details_screen.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: StoryForm(
        headingText: 'Add Story',
        submitLabel: 'Save Story',
        onSubmit: (story) async {
          try {
            await SupabaseService.instance.addStory(story);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Could not save story: $e')));
            return;
          }
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => StoryDetailsScreen(storyId: story.id),
            ),
          );
        },
      ),
    );
  }
}
