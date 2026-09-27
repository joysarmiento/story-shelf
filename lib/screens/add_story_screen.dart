import 'package:flutter/material.dart';

import '../data/sample_data.dart';
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
          // TODO: replace with SupabaseService.instance.addStory(story)
          // once the stories table exists.
          sampleStories.add(story);
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
