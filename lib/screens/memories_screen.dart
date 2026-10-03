import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/memory_card.dart';
import 'story_details_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Medium? _selectedMedium;

  static const _mediumFilters = [
    null,
    Medium.movie,
    Medium.manhwa,
    Medium.anime,
    Medium.book,
    Medium.drama,
    Medium.manga,
    Medium.tvSeries,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Memory> get _filteredMemories {
    // TODO: replace sampleMemories with SupabaseService.instance
    // .getMemoriesForUser() once the memories table has real rows to read.
    final query = _query.trim().toLowerCase();

    bool matchesQuery(Memory m) {
      if (query.isEmpty) return true;
      return [
        m.title,
        m.content,
        m.quote,
        m.storyTitle,
        m.progressReference,
      ].any((text) => text != null && text.toLowerCase().contains(query));
    }

    final memories = sampleMemories.where((memory) {
      final matchesMedium =
          _selectedMedium == null || memory.storyMedium == _selectedMedium;
      return matchesQuery(memory) && matchesMedium;
    }).toList();

    memories.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    return memories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memories = _filteredMemories;
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'docs/assets/images/memories-wordmark.png',
                        height: 75,
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
                ),
                const SizedBox(height: AppTheme.spaceXs),
                SizedBox(
                  height: 35,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                      ),
                      itemCount: _mediumFilters.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppTheme.spaceSm),
                      itemBuilder: (context, index) {
                        final medium = _mediumFilters[index];
                        return FilterChipPill(
                          label: medium?.label ?? 'All',
                          selected: _selectedMedium == medium,
                          onTap: () => setState(() => _selectedMedium = medium),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                  ),
                  child: AppSearchBar(
                    controller: _searchController,
                    hint: 'Search your memories',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All Memories',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Expanded(
                  child: memories.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppTheme.spaceMd,
                              0,
                              AppTheme.spaceMd,
                              100,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_border,
                                  size: 48,
                                  color: AppTheme.secondary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spaceMd),
                                Text(
                                  hasQuery
                                      ? 'No results for "${_query.trim()}"'
                                      : _selectedMedium != null
                                      ? 'No ${_selectedMedium!.label.toLowerCase()} memories yet'
                                      : 'No memories yet',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spaceXs),
                                Text(
                                  hasQuery
                                      ? 'Try a different word or title.'
                                      : 'Open a story and tap + add to save a memory.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.spaceMd,
                            0,
                            AppTheme.spaceMd,
                            96,
                          ),
                          itemCount: memories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppTheme.spaceListGap),
                          itemBuilder: (context, index) {
                            final memory = memories[index];
                            return MemoryCard(
                              memory: memory,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StoryDetailsScreen(
                                      storyId: memory.storyId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: AppTab.memories,
              onTap: (index) =>
                  navigateToTab(context, index, currentIndex: AppTab.memories),
            ),
          ),
        ],
      ),
    );
  }
}
