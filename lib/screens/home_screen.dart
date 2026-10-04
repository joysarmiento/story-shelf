import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/memory_card.dart';
import '../widgets/section_header.dart';
import '../widgets/story_poster_card.dart';
import '../utils/date_format.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load your shelf: $e')));
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
    final memoryOfTheDay = _memories.isNotEmpty ? _memories.first : null;

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
                      if (memoryOfTheDay != null)
                        _MemoryOfTheDayBanner(memory: memoryOfTheDay),
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
