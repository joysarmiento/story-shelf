import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../utils/date_format.dart';
import '../widgets/bottom_nav_bar.dart';
import 'edit_memory_screen.dart';

class MemoryDetailsScreen extends StatefulWidget {
  const MemoryDetailsScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  State<MemoryDetailsScreen> createState() => _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState extends State<MemoryDetailsScreen> {
  Memory? _memory;
  int? _releaseYear;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final memory = await SupabaseService.instance.getMemory(widget.memoryId);
      final story = memory == null
          ? null
          : await SupabaseService.instance.getStory(memory.storyId);
      if (!mounted) return;
      setState(() {
        _memory = memory;
        _releaseYear = story?.releaseYear;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load memory: $e')));
    }
  }

  Future<void> _openEdit(Memory memory) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditMemoryScreen(memory: memory)));
    if (mounted) _load();
  }

  Future<void> _confirmDelete(Memory memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text('This memory will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await SupabaseService.instance.deleteMemory(memory.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete memory: $e')));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memory = _memory;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (memory == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          child: Center(
            child: Text('Memory not found', style: theme.textTheme.bodyMedium),
          ),
        ),
      );
    }

    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _Banner(memory: memory, releaseYear: _releaseYear),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: media.size.height * 0.55,
                      ),
                      child: _MemoryCard(
                        memory: memory,
                        onEdit: () => _openEdit(memory),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(memory),
                      icon: Icon(Icons.delete_outline, color: AppTheme.error),
                      label: Text(
                        'Delete memory',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: AppTab.library,
              onTap: (index) => navigateToTab(context, index, currentIndex: -1),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory, required this.onEdit});

  final Memory memory;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.45,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  memory.cleanTitle ?? memory.entryType.label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Semantics(
                button: true,
                label: 'Edit memory',
                child: GestureDetector(
                  onTap: onEdit,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.secondary,
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppTheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            memory.progressReference ?? memory.entryType.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Date: ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: formatLongDate(memory.dateCreated)),
              ],
            ),
            style: body,
          ),
          if (memory.quote != null) ...[
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              '“${memory.quote}”',
              textAlign: TextAlign.justify,
              style: body,
            ),
          ],
          const SizedBox(height: AppTheme.spaceMd),
          Text(memory.content, textAlign: TextAlign.justify, style: body),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.memory, this.releaseYear});

  final Memory memory;
  final int? releaseYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final cover = memory.storyCoverPath;
    final meta = [
      if (memory.storyCreator != null) memory.storyCreator!,
      if (releaseYear != null) releaseYear.toString(),
    ].join(' • ');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              cover != null
                  ? Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: AppTheme.secondary),
                    )
                  : Container(color: AppTheme.secondary),
              Positioned(
                bottom: -2,
                left: 0,
                right: 0,
                height: 112,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(0, 251, 249, 236),
                          AppTheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppTheme.spaceMd + topInset,
                left: AppTheme.spaceMd,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left, color: AppTheme.onPrimary),
                      Text('Back', style: TextStyle(color: AppTheme.onPrimary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: -10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (memory.storyMedium != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    memory.storyMedium!.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimary,
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                memory.storyTitle ?? 'Untitled story',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.error,
                  fontSize: 20,
                ),
              ),
              if (meta.isNotEmpty)
                Text(
                  meta,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
