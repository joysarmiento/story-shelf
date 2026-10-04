import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../services/supabase_service.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/story_poster_card.dart';
import 'add_story_screen.dart';
import 'story_details_screen.dart';

enum _LibrarySort { alphabetical, latestRead }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Medium? _selectedMedium;
  StoryStatus? _selectedStatus;
  _LibrarySort? _selectedSort;
  bool _favoritesOnly = false;
  final _searchController = TextEditingController();
  String _query = '';

  List<Story> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SupabaseService.instance.getStoriesForUser();
      if (!mounted) return;
      setState(() {
        _stories = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load stories: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final query = _query.trim().toLowerCase();
    return _stories.where((story) {
      final matchesQuery =
          query.isEmpty ||
          story.title.toLowerCase().contains(query) ||
          (story.creator?.toLowerCase().contains(query) ?? false);
      final matchesMedium =
          _selectedMedium == null || story.medium == _selectedMedium;
      final matchesFavorite = !_favoritesOnly || story.isFavorite;
      final matchesStatus =
          _selectedStatus == null || story.status == _selectedStatus;
      return matchesQuery && matchesMedium && matchesFavorite && matchesStatus;
    }).toList();
  }

  List<Story> _sorted(List<Story> stories) {
    switch (_selectedSort) {
      case _LibrarySort.alphabetical:
        return [...stories]..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _LibrarySort.latestRead:
        return [...stories]..sort((a, b) {
          final aRead = a.lastReadAt;
          final bRead = b.lastReadAt;
          if (aRead == null && bRead == null) {
            return b.dateAdded.compareTo(a.dateAdded);
          }
          if (aRead == null) return 1;
          if (bRead == null) return -1;
          return bRead.compareTo(aRead);
        });
      case null:
        return stories;
    }
  }

  Future<void> _openFilterSort() async {
    final choice = await showModalBottomSheet<_FilterSortChoice>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    labelColor: AppTheme.error,
                    unselectedLabelColor: AppTheme.onSurface,
                    indicatorColor: AppTheme.error,
                    dividerColor: AppTheme.secondary.withValues(alpha: 0.4),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: theme.textTheme.bodyMedium,
                    tabs: const [
                      Tab(text: 'Filter'),
                      Tab(text: 'Sort'),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              'Filter by status',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            _StatusOption(
                              label: 'All',
                              selected: _selectedStatus == null,
                              onTap: () => Navigator.of(
                                context,
                              ).pop(_FilterSortChoice(null, _selectedSort)),
                            ),
                            for (final status in StoryStatus.values)
                              _StatusOption(
                                label: status.label,
                                selected: _selectedStatus == status,
                                onTap: () => Navigator.of(
                                  context,
                                ).pop(_FilterSortChoice(status, _selectedSort)),
                              ),
                          ],
                        ),
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              'Sort by',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            _StatusOption(
                              label: 'Alphabetical (A-Z)',
                              selected:
                                  _selectedSort == _LibrarySort.alphabetical,
                              onTap: () => Navigator.of(context).pop(
                                _FilterSortChoice(
                                  _selectedStatus,
                                  _selectedSort == _LibrarySort.alphabetical
                                      ? null
                                      : _LibrarySort.alphabetical,
                                ),
                              ),
                            ),
                            _StatusOption(
                              label: 'Latest read',
                              selected:
                                  _selectedSort == _LibrarySort.latestRead,
                              onTap: () => Navigator.of(context).pop(
                                _FilterSortChoice(
                                  _selectedStatus,
                                  _selectedSort == _LibrarySort.latestRead
                                      ? null
                                      : _LibrarySort.latestRead,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (choice == null || !mounted) return;
    setState(() {
      _selectedStatus = choice.status;
      _selectedSort = choice.sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stories = _sorted(_filteredStories);

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
                      Text('Library', style: theme.textTheme.headlineMedium),
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
                const SizedBox(height: AppTheme.spaceMd),
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
                      separatorBuilder: (_, _) =>
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
                    hint: 'Search your library',
                    onChanged: (value) => setState(() => _query = value),
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
                        onPressed: _openFilterSort,
                        icon: Icon(
                          Icons.filter_list,
                          color:
                              (_selectedStatus != null || _selectedSort != null)
                              ? AppTheme.error
                              : AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Expanded(
                  child: Stack(
                    children: [
                      if (_loading)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (stories.isEmpty)
                        Positioned.fill(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceMd,
                                ),
                                child: EmptyState(
                                  icon: Icons.auto_stories_outlined,
                                  title: _query.trim().isNotEmpty
                                      ? 'No results for "${_query.trim()}"'
                                      : _favoritesOnly
                                      ? 'No favorites yet'
                                      : _selectedMedium != null
                                      ? 'No ${_selectedMedium!.label.toLowerCase()} stories yet'
                                      : 'No stories yet',
                                  message: _query.trim().isNotEmpty
                                      ? 'Try a different title or creator.'
                                      : 'Tap + to add your story.',
                                ),
                              ),
                            ),
                          ),
                        )
                      else
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
                                childAspectRatio: AppTheme.storyCardAspectRatio,
                              ),
                          itemCount: stories.length,
                          itemBuilder: (context, index) {
                            final story = stories[index];
                            return StoryPosterCard(
                              story: story,
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (_) => StoryDetailsScreen(
                                          storyId: story.id,
                                        ),
                                      ),
                                    )
                                    .then((_) => _load());
                              },
                            );
                          },
                        ),
                      Positioned(
                        right: 8,
                        bottom: 96,
                        child: FloatingActionButton(
                          backgroundColor: AppTheme.secondary,
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => const AddStoryScreen(),
                                  ),
                                )
                                .then((_) => _load());
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
              onTap: (index) =>
                  navigateToTab(context, index, currentIndex: AppTab.library),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSortChoice {
  const _FilterSortChoice(this.status, this.sort);
  final StoryStatus? status;
  final _LibrarySort? sort;
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: selected ? AppTheme.error : AppTheme.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: selected ? Icon(Icons.check, color: AppTheme.error) : null,
    );
  }
}
