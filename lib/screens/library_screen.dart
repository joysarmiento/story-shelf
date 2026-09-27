import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/story_poster_card.dart';
import 'home_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Medium? _selectedMedium; // null = "All"
  bool _favoritesOnly = false;

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

  List<Story> get _filteredStories {
    // TODO: replace sampleStories with SupabaseService.instance
    // .getStoriesForUser() once the stories table and CRUD exist.
    return sampleStories.where((story) {
      final matchesMedium =
          _selectedMedium == null || story.medium == _selectedMedium;
      final matchesFavorite = !_favoritesOnly || story.isFavorite;
      return matchesMedium && matchesFavorite;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stories = _filteredStories;

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
                        'docs/assets/images/library-wordmark.png',
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
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
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
                const SizedBox(height: AppTheme.spaceMd),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'All Stories',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _favoritesOnly = !_favoritesOnly),
                        icon: Icon(
                          _favoritesOnly
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: AppTheme.secondary,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: open a bottom sheet with the Not
                          // Started/Started/Completed status filter.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Status filter coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.filter_list,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Expanded(
                  child: Stack(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spaceMd,
                          0,
                          AppTheme.spaceMd,
                          96,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppTheme.spaceSm,
                              mainAxisSpacing: AppTheme.spaceSm,
                              childAspectRatio: 2 / 3,
                            ),
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return StoryPosterCard(
                            story: story,
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //   builder: (_) => StoryDetailsScreen(storyId: story.id),
                              // ));
                            },
                          );
                        },
                      ),
                      Positioned(
                        right: 8,
                        // raised so it clears the floating nav bar
                        bottom: 96,
                        child: FloatingActionButton(
                          backgroundColor: AppTheme.secondary,
                          onPressed: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(builder: (_) => const AddStoryScreen()),
                            // );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add Story coming soon'),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.add,
                            color: AppTheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
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
              currentIndex: 1,
              onTap: (index) {
                if (index == 1) return;
                if (index == 0) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                  return;
                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Coming soon')));
              },
            ),
          ),
        ],
      ),
    );
  }
}
