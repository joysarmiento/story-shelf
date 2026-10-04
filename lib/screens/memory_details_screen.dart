import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
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
  Memory? get _memory {
    // TODO: replace with a SupabaseService memory fetch once it exists.
    for (final m in sampleMemories) {
      if (m.id == widget.memoryId) return m;
    }
    return null;
  }

  Future<void> _openEdit(Memory memory) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditMemoryScreen(memory: memory)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memory = _memory;

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
              _Banner(memory: memory),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: media.size.height * 0.5,
                  ),
                  child: _MemoryCard(
                    memory: memory,
                    onEdit: () => _openEdit(memory),
                  ),
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
                  child: const CircleAvatar(
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
  const _Banner({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cover = memory.storyCoverPath;
    final meta = [
      if (memory.storyCreator != null) memory.storyCreator!,
      _releaseYear(),
    ].whereType<String>().join(' • ');

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          cover != null
              ? Image.network(
                  cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppTheme.secondary),
                )
              : Container(color: AppTheme.secondary),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
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
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chevron_left, color: AppTheme.onPrimary),
                        Text(
                          'Back',
                          style: TextStyle(color: AppTheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
          ),
        ],
      ),
    );
  }

  String? _releaseYear() {
    for (final Story s in sampleStories) {
      if (s.id == memory.storyId) return s.releaseYear?.toString();
    }
    return null;
  }
}
