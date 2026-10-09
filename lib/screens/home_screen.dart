import 'dart:async';

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../utils/date_format.dart';
import '../utils/error_message.dart';
import '../utils/memory_of_the_day.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/memory_card.dart';
import '../widgets/section_header.dart';
import '../widgets/story_poster_card.dart';
import 'library_screen.dart';
import 'memories_screen.dart';
import 'memory_details_screen.dart';
import 'story_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Story> _stories = [];
  List<Memory> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final (stories, memories) = await (
        SupabaseService.instance.getStoriesForUser(),
        SupabaseService.instance.getAllMemoriesForUser(),
      ).wait;
      if (!mounted) return;
      setState(() {
        _stories = stories;
        _memories = memories;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load your shelf. ${friendlyError(e)}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final continueStories =
        _stories.where((s) => s.status == StoryStatus.inProgress).toList()
          ..sort(
            (a, b) => (b.lastReadAt ?? b.dateAdded).compareTo(
              a.lastReadAt ?? a.dateAdded,
            ),
          );
    final recentMemories = _memories.take(3).toList();
    final hasNoStories = _stories.isEmpty;
    final memoriesOfTheDay = pickMemoriesOfTheDay(_memories);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceMd,
                      AppTheme.spaceSm,
                      AppTheme.spaceMd,
                      96,
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Shelf.',
                            style: theme.textTheme.headlineMedium,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                'docs/assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      if (memoriesOfTheDay.isNotEmpty)
                        _MemoriesOfTheDay(
                          memories: memoriesOfTheDay,
                          onTap: (memory) async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    MemoryDetailsScreen(memoryId: memory.id),
                              ),
                            );
                            if (mounted) _load();
                          },
                        ),
                      const SizedBox(height: AppTheme.spaceSectionGap),
                      SectionHeader(
                        title: 'Continue your stories',
                        actionLabel: 'see all',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LibraryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      if (continueStories.isEmpty)
                        EmptyState(
                          bordered: true,
                          iconSize: 40,
                          icon: Icons.auto_stories_outlined,
                          title: hasNoStories
                              ? 'Your shelf is empty'
                              : 'No stories in progress',
                          message: hasNoStories
                              ? 'Add your first story from the Library.'
                              : 'Start a story from your Library to see it here.',
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: AppTheme.spaceSm,
                                mainAxisSpacing: AppTheme.spaceSm,
                                childAspectRatio: AppTheme.storyCardAspectRatio,
                              ),
                          itemCount: continueStories.take(3).length,
                          itemBuilder: (context, index) {
                            final story = continueStories[index];
                            return StoryPosterCard(
                              story: story,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StoryDetailsScreen(storyId: story.id),
                                  ),
                                );
                                if (mounted) _load();
                              },
                            );
                          },
                        ),

                      const SizedBox(height: AppTheme.spaceSectionGap),
                      SectionHeader(
                        title: 'Recent memories',
                        actionLabel: 'see all',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MemoriesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      if (recentMemories.isEmpty)
                        const EmptyState(
                          bordered: true,
                          iconSize: 40,
                          icon: Icons.sticky_note_2_outlined,
                          title: 'No memories yet',
                          message:
                              'Open a story and tap + add to save a memory.',
                        ),
                      for (final memory in recentMemories) ...[
                        MemoryCard(
                          memory: memory,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    MemoryDetailsScreen(memoryId: memory.id),
                              ),
                            );
                            if (mounted) _load();
                          },
                        ),
                        const SizedBox(height: AppTheme.spaceListGap),
                      ],
                    ],
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: 0,
              onTap: (index) =>
                  navigateToTab(context, index, currentIndex: AppTab.home),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoriesOfTheDay extends StatefulWidget {
  const _MemoriesOfTheDay({required this.memories, required this.onTap});

  final List<Memory> memories;
  final ValueChanged<Memory> onTap;

  @override
  State<_MemoriesOfTheDay> createState() => _MemoriesOfTheDayState();
}

class _MemoriesOfTheDayState extends State<_MemoriesOfTheDay> {
  static const _interval = Duration(seconds: 6);

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _MemoriesOfTheDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= widget.memories.length) _index = 0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.memories.length < 2) return;
    _timer = Timer.periodic(_interval, (_) => _goTo(_index + 1));
  }

  void _goTo(int i) {
    final n = widget.memories.length;
    if (!mounted || n == 0) return;
    setState(() => _index = ((i % n) + n) % n);
  }

  void _manualGoTo(int i) {
    _goTo(i);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final memories = widget.memories;
    return GestureDetector(
      onTap: () => widget.onTap(memories[_index]),
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -200) _manualGoTo(_index + 1);
        if (v > 200) _manualGoTo(_index - 1);
      },
      child: Column(
        children: [
          Stack(
            children: [
              for (var i = 0; i < memories.length; i++)
                IgnorePointer(
                  ignoring: i != _index,
                  child: AnimatedOpacity(
                    opacity: i == _index ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: _MemoryOfTheDayBanner(memory: memories[i]),
                  ),
                ),
            ],
          ),
          if (memories.length > 1) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < memories.length; i++)
                  GestureDetector(
                    onTap: () => _manualGoTo(i),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: i == _index ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? AppTheme.primary
                              : AppTheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MemoryOfTheDayBanner extends StatelessWidget {
  const _MemoryOfTheDayBanner({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: memory.storyCoverPath != null
                ? Image.network(
                    memory.storyCoverPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: AppTheme.secondary),
                  )
                : Container(color: AppTheme.secondary),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.75),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Memory From This Day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.error,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 34),
                Text(
                  memory.storyTitle ?? memory.cleanTitle ?? 'Untitled memory',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.onPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXxs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      [
                        if (memory.storyCreator != null) memory.storyCreator!,
                        if (memory.storyMedium != null)
                          memory.storyMedium!.label,
                      ].join(' • '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onPrimary,
                      ),
                    ),
                    Text(
                      formatLongDate(memory.dateCreated),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                if (memory.quote != null) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    '"${memory.quote}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
