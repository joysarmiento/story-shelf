import 'package:flutter/material.dart';

import '../models/story.dart';
import '../services/supabase_service.dart';
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
          try {
            await SupabaseService.instance.addMemory(memory);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not save memory: $e')),
            );
            return;
          }
          if (!context.mounted) return;
          Navigator.of(context).pop(memory);
        },
      ),
    );
  }
}
