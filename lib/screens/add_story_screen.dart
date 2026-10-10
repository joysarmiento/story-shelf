import 'package:flutter/material.dart';

import '../models/story_search_result.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/error_message.dart';
import '../widgets/story_form.dart';
import 'story_details_screen.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen({super.key, this.prefill});
  final StorySearchResult? prefill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: StoryForm(
        headingText: 'Add Story',
        submitLabel: 'Save Story',
        prefill: prefill,
        onSubmit: (story) async {
          try {
            await SupabaseService.instance.addStory(story);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not save story. ${friendlyError(e)}'),
              ),
            );
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
