import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../utils/date_format.dart';
import '../widgets/bottom_nav_bar.dart';
import 'add_memory_screen.dart';
import 'edit_story_screen.dart';
import 'memory_details_screen.dart';

class StoryDetailsScreen extends StatefulWidget {
  const StoryDetailsScreen({super.key, required this.storyId});

  final String storyId;

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  String _statusDisplayLabel(StoryStatus status, Medium medium) {
    switch (status) {
      case StoryStatus.notStarted:
        return 'Not Started';
      case StoryStatus.completed:
        return 'Completed';
      case StoryStatus.inProgress:
        switch (medium) {
          case Medium.book:
          case Medium.manhwa:
          case Medium.manga:
            return 'Currently Reading';
          case Medium.movie:
          case Medium.drama:
          case Medium.anime:
          case Medium.tvSeries:
            return 'Currently Watching';
        }
    }
  }

  Story get _story => sampleStories.firstWhere((s) => s.id == widget.storyId);

  List<Memory> get _memories {
    // TODO: replace with SupabaseService.instance
    // .getMemoriesForStory(widget.storyId) once Add Memory exists and the
    // memories table has real rows to read.
    return sampleMemories.where((m) => m.storyId == widget.storyId).toList();
  }

  Future<void> _openEdit() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditStoryScreen(story: _story)));
    if (mounted) setState(() {});
  }

  void _toggleFavorite() {
    final index = sampleStories.indexWhere((s) => s.id == widget.storyId);
    if (index == -1) return;
    setState(() {
      sampleStories[index] = sampleStories[index].copyWith(
        isFavorite: !sampleStories[index].isFavorite,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final story = _story;
    final memories = _memories;
    final unit = story.medium.progressUnitLabel;
    final percent = (story.progressFraction * 100).round();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _Banner(
                story: story,
                isFavorite: story.isFavorite,
                onToggleFavorite: _toggleFavorite,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 76),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.secondary.withValues(alpha: 0.3),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'STATUS',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      _statusDisplayLabel(
                                        story.status,
                                        story.medium,
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: AppTheme.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'RATING',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  _StaticStars(rating: story.rating ?? 0),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          if (story.totalProgress != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$unit ${story.currentProgress.toInt()} of '
                                  '${story.totalProgress!.toInt()}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '$percent%',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spaceXs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: story.progressFraction,
                                minHeight: 8,
                                backgroundColor: AppTheme.surface,
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: _openEdit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'Update',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSectionGap),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Memories',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMemoryScreen(story: story),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                          child: Text(
                            '+ add',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    for (final memory in memories) ...[
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MemoryDetailsScreen(memoryId: memory.id),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                        child: _StoryMemoryTile(memory: memory),
                      ),
                      const SizedBox(height: AppTheme.spaceListGap),
                    ],
                    if (memories.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spaceLg,
                          horizontal: AppTheme.spaceMd,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '₍^. .^₎⟆',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceSm),
                            Text(
                              'No memories yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceXs),
                            Text(
                              'Tap + add to save a memory.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
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
              currentIndex: 1,
              onTap: (index) => navigateToTab(context, index, currentIndex: -1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.story,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Story story;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 200 + topInset,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              story.coverPath != null
                  ? Image.network(
                      story.coverPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppTheme.secondary),
                    )
                  : Container(color: AppTheme.secondary),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AppTheme.surface.withValues(alpha: 0.20),
                  ),
                ),
              ),
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
              Positioned(
                top: AppTheme.spaceMd + topInset,
                right: AppTheme.spaceMd,
                child: GestureDetector(
                  onTap: onToggleFavorite,
                  child: CircleAvatar(
                    backgroundColor: AppTheme.surface,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppTheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: -35,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 140,
                  child: story.coverPath != null
                      ? Image.network(
                          story.coverPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppTheme.secondary),
                        )
                      : Container(color: AppTheme.secondary),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spaceSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            width: 1,
                          ),
                        ),
                        child: Text(
                          story.medium.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.error,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        [
                          if (story.creator != null) story.creator!,
                          if (story.releaseYear != null)
                            story.releaseYear.toString(),
                        ].join(' • '),
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
        ),
      ],
    );
  }
}

class _StaticStars extends StatelessWidget {
  const _StaticStars({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final threshold = index + 1;
        final icon = rating >= threshold
            ? Icons.star
            : (rating >= threshold - 0.5 ? Icons.star_half : Icons.star_border);
        return Icon(icon, size: 18, color: const Color(0xFFD9A441));
      }),
    );
  }
}

class _StoryMemoryTile extends StatelessWidget {
  const _StoryMemoryTile({required this.memory});
  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metaLabel = [
      if (memory.progressReference != null) memory.progressReference!,
      formatLongDate(memory.dateCreated),
    ].join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (memory.cleanTitle != null)
            Text(
              memory.cleanTitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            metaLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.onPrimary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
            child: Divider(color: AppTheme.onPrimary, height: 1),
          ),
          if (memory.quote != null) ...[
            Text(
              '"${memory.quote}"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXs),
          ],
          Text(
            memory.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
