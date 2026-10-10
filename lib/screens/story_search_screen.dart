import 'dart:async';

import 'package:flutter/material.dart';

import '../models/story.dart';
import '../models/story_search_result.dart';
import '../services/story_search_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/error_message.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_pill.dart';
import 'story_details_screen.dart';

class StorySearchOutcome {
  const StorySearchOutcome.manual() : result = null;
  const StorySearchOutcome.prefilled(this.result);

  final StorySearchResult? result;
}

class StorySearchScreen extends StatefulWidget {
  const StorySearchScreen({super.key});

  @override
  State<StorySearchScreen> createState() => _StorySearchScreenState();
}

class _StorySearchScreenState extends State<StorySearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;

  Medium _medium = Medium.book;
  List<StorySearchResult> _results = [];
  Map<String, String> _shelf = {};
  bool _loading = false;
  bool _searched = false;
  bool _picking = false;
  String? _error;

  String get _query => _controller.text.trim();

  @override
  void initState() {
    super.initState();
    _loadShelf();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadShelf() async {
    try {
      final stories = await SupabaseService.instance.getStoriesForUser();
      if (!mounted) return;
      setState(() {
        _shelf = {
          for (final s in stories)
            StorySearchResult.shelfKeyFor(s.title, s.medium): s.id,
        };
      });
    } catch (_) {}
  }

  void _resetResults() {
    _requestId++;
    _results = [];
    _loading = false;
    _searched = false;
    _error = null;
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    if (_query.length < 2) {
      setState(_resetResults);
      return;
    }
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  void _selectMedium(Medium m) {
    if (m == _medium) return;
    _debounce?.cancel();
    setState(() {
      _medium = m;
      _resetResults();
    });
    if (_query.length >= 2) _search();
  }

  Future<void> _search() async {
    final q = _query;
    if (q.length < 2) return;
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await StorySearchService.instance.search(q, _medium);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = r;
        _searched = true;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = [];
        _searched = true;
        _error = friendlyError(e);
      });
    } finally {
      if (mounted && id == _requestId) setState(() => _loading = false);
    }
  }

  Future<void> _pick(StorySearchResult r) async {
    final existingId = _shelf[r.shelfKey];
    if (existingId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StoryDetailsScreen(storyId: existingId),
        ),
      );
      return;
    }
    setState(() => _picking = true);
    final full = await StorySearchService.instance.withDetails(r);
    if (!mounted) return;
    Navigator.of(context).pop(StorySearchOutcome.prefilled(full));
  }

  void _addManually() {
    Navigator.of(context).pop(const StorySearchOutcome.manual());
  }

  String get _sourceNote => switch (_medium) {
    Medium.book => 'Book data from Open Library.',
    Medium.comic => 'Comic data from AniList.',
    Medium.movie || Medium.series =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.',
  };

  Widget _centered(Widget child) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: child,
    ),
  );

  Widget _buildBody() {
    if (_error != null) {
      return _centered(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(
              icon: Icons.cloud_off,
              title: "Couldn't search right now",
              message: _error!,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            TextButton(
              onPressed: _search,
              child: Text(
                'Try again',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    }
    if (_query.length < 2) {
      return _centered(
        const EmptyState(
          icon: Icons.search,
          title: 'Find your story',
          message: 'Pick a type, then search by title.',
        ),
      );
    }
    if (_loading && _results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }
    if (_searched && _results.isEmpty) {
      return _centered(
        const EmptyState(
          icon: Icons.search_off,
          title: 'No results',
          message: 'Try another spelling, or add it manually.',
        ),
      );
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppTheme.secondary.withValues(alpha: 0.4)),
      itemBuilder: (context, index) {
        final r = _results[index];
        return _ResultTile(
          result: r,
          onShelf: _shelf.containsKey(r.shelfKey),
          onTap: () => _pick(r),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBackButton(),
                      const SizedBox(height: AppTheme.spaceXxs),
                      Text('Add Story', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        'Choose a type, then search for the title.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                SizedBox(
                  height: 35,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMd,
                    ),
                    child: Row(
                      children: [
                        for (final m in Medium.values) ...[
                          Expanded(
                            child: FilterChipPill(
                              label: m.label,
                              selected: _medium == m,
                              onTap: () => _selectMedium(m),
                            ),
                          ),
                          if (m != Medium.values.last)
                            const SizedBox(width: AppTheme.spaceSm),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                  ),
                  child: AppSearchBar(
                    controller: _controller,
                    hint: 'Search for a ${_medium.label.toLowerCase()}',
                    onChanged: _onChanged,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Expanded(child: _buildBody()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMd,
                    AppTheme.spaceSm,
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sourceNote,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _addManually,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: BorderSide(color: AppTheme.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Add manually',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_picking)
              Positioned.fill(
                child: AbsorbPointer(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.onShelf,
    required this.onTap,
  });

  final StorySearchResult result;
  final bool onShelf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = [
      if (result.creator != null && result.creator!.isNotEmpty) result.creator!,
      if (result.year != null) result.year.toString(),
    ].join(' · ');

    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${result.title}${meta.isEmpty ? '' : ', $meta'}'
          '${onShelf ? ', already on your shelf' : ''}',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
          child: Row(
            children: [
              _Cover(url: result.coverUrl),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spaceXxs),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (onShelf) ...[
                      const SizedBox(height: AppTheme.spaceXs),
                      const _ShelfBadge(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Icon(
                onShelf ? Icons.chevron_right : Icons.add_circle_outline,
                color: onShelf ? AppTheme.onSurface : AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.url});

  final String? url;

  Widget _placeholder() => Container(
    color: AppTheme.storyTintBeige,
    alignment: Alignment.center,
    child: const Icon(Icons.menu_book, color: AppTheme.onPrimary),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: AspectRatio(
        aspectRatio: AppTheme.storyCardAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url == null
              ? _placeholder()
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                ),
        ),
      ),
    );
  }
}

class _ShelfBadge extends StatelessWidget {
  const _ShelfBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppTheme.onSurface),
          const SizedBox(width: AppTheme.spaceXs),
          Text('On your shelf', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
