import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_form.dart';

class EditMemoryScreen extends StatelessWidget {
  const EditMemoryScreen({super.key, required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: MemoryForm(
        headingText: 'Edit Memory',
        submitLabel: 'Save Memory Edits',
        initialMemory: memory,
        onSubmit: (updated) async {
          try {
            await SupabaseService.instance.updateMemory(updated);
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
