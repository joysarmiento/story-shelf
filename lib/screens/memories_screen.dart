import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../utils/date_format.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/memory_card.dart';
import 'memory_details_screen.dart';

enum _DatePreset { any, last7, last30, thisYear, custom }

extension on _DatePreset {
  String get label => switch (this) {
    _DatePreset.any => 'Any date',
    _DatePreset.last7 => 'Last 7 days',
    _DatePreset.last30 => 'Last 30 days',
    _DatePreset.thisYear => 'This year',
    _DatePreset.custom => 'Custom range...',
  };
}

class _FilterSortChoice {
  const _FilterSortChoice(this.preset, this.newestFirst);
  final _DatePreset preset;
  final bool newestFirst;
}

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Medium? _selectedMedium;
  bool _newestFirst = true;
  _DatePreset _datePreset = _DatePreset.any;
  DateTimeRange? _customRange;

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

  List<Memory> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SupabaseService.instance.getAllMemoriesForUser();
      if (!mounted) return;
      setState(() {
        _memories = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load memories: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Memory> get _filteredMemories {
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

    final dateRange = _activeDateRange;

    bool matchesDate(Memory m) {
      if (dateRange == null) return true;
      final end = DateTime(
        dateRange.end.year,
        dateRange.end.month,
        dateRange.end.day + 1,
      );
      return !m.dateCreated.isBefore(dateRange.start) &&
          m.dateCreated.isBefore(end);
    }

    final memories = _memories.where((memory) {
      final matchesMedium =
          _selectedMedium == null || memory.storyMedium == _selectedMedium;
      return matchesQuery(memory) && matchesMedium && matchesDate(memory);
    }).toList();

    memories.sort(
      (a, b) => _newestFirst
          ? b.dateCreated.compareTo(a.dateCreated)
          : a.dateCreated.compareTo(b.dateCreated),
    );
    return memories;
  }

  DateTimeRange? get _activeDateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_datePreset) {
      case _DatePreset.any:
        return null;
      case _DatePreset.last7:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case _DatePreset.last30:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case _DatePreset.thisYear:
        return DateTimeRange(start: DateTime(today.year), end: today);
      case _DatePreset.custom:
        return _customRange;
    }
  }

  bool get _hasActiveFilterOrSort =>
      _datePreset != _DatePreset.any || !_newestFirst;

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
                              'Filter by date',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            for (final preset in _DatePreset.values)
                              _OptionTile(
                                label:
                                    preset == _DatePreset.custom &&
                                        _datePreset == _DatePreset.custom &&
                                        _customRange != null
                                    ? '${formatLongDate(_customRange!.start)} - '
                                          '${formatLongDate(_customRange!.end)}'
                                    : preset.label,
                                selected: _datePreset == preset,
                                onTap: () => Navigator.of(
                                  context,
                                ).pop(_FilterSortChoice(preset, _newestFirst)),
                              ),
                          ],
                        ),
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              'Sort by date',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            _OptionTile(
                              label: 'Newest first',
                              selected: _newestFirst,
                              onTap: () => Navigator.of(
                                context,
                              ).pop(_FilterSortChoice(_datePreset, true)),
                            ),
                            _OptionTile(
                              label: 'Oldest first',
                              selected: !_newestFirst,
                              onTap: () => Navigator.of(
                                context,
                              ).pop(_FilterSortChoice(_datePreset, false)),
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

    if (choice.preset == _DatePreset.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        initialDateRange: _customRange,
      );
      if (!mounted) return;
      setState(() {
        _newestFirst = choice.newestFirst;
        if (picked != null) {
          _customRange = picked;
          _datePreset = _DatePreset.custom;
        }
      });
      return;
    }

    setState(() {
      _datePreset = choice.preset;
      _newestFirst = choice.newestFirst;
    });
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
                      Text('Memories', style: theme.textTheme.headlineMedium),
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
                const SizedBox(height: AppTheme.spaceSm),
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
                    hint: 'Search your memories',
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
                          'All Memories',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Filter and sort',
                        onPressed: _openFilterSort,
                        icon: Icon(
                          Icons.filter_list,
                          color: _hasActiveFilterOrSort
                              ? AppTheme.error
                              : AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : memories.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppTheme.spaceMd,
                              0,
                              AppTheme.spaceMd,
                              100,
                            ),
                            child: EmptyState(
                              icon: Icons.sticky_note_2_outlined,
                              title: hasQuery
                                  ? 'No results for "${_query.trim()}"'
                                  : _datePreset != _DatePreset.any
                                  ? 'No memories in this date range'
                                  : _selectedMedium != null
                                  ? 'No ${_selectedMedium!.label.toLowerCase()} memories yet'
                                  : 'No memories yet',
                              message: hasQuery
                                  ? 'Try a different word or title.'
                                  : 'Open a story and tap + add to save a memory.',
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
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppTheme.spaceListGap),
                          itemBuilder: (context, index) {
                            final memory = memories[index];
                            return MemoryCard(
                              memory: memory,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MemoryDetailsScreen(
                                      memoryId: memory.id,
                                    ),
                                  ),
                                );
                                if (mounted) _load();
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
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
