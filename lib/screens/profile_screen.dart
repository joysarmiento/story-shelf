import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/story.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_avatar.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    // Name / picture may have changed in Edit Profile.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = SupabaseService.instance;

    // TODO: replace with SupabaseService.instance.getStoriesForUser() /
    // getMemoriesForUser() once those are wired up.
    final stories = sampleStories;
    final completed = stories
        .where((s) => s.status == StoryStatus.completed)
        .length;

    final byMedium = <Medium, int>{};
    for (final s in stories) {
      byMedium[s.medium] = (byMedium[s.medium] ?? 0) + 1;
    }
    final rows = byMedium.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceSm,
                AppTheme.spaceMd,
                96,
              ),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    button: true,
                    label: 'Settings',
                    child: GestureDetector(
                      onTap: _openSettings,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.secondary,
                        child: Icon(
                          Icons.settings,
                          color: AppTheme.onPrimary,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(child: ProfileAvatar(imageUrl: service.avatarUrl)),
                const SizedBox(height: AppTheme.spaceMd),
                Text(
                  service.displayName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  '@${service.username}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSectionGap),
                _StatsCard(
                  stories: stories.length,
                  completed: completed,
                  memories: sampleMemories.length,
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _MediumBreakdownCard(rows: rows, total: stories.length),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: AppTab.profile,
              onTap: (index) =>
                  navigateToTab(context, index, currentIndex: AppTab.profile),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppTheme.surfaceVariant,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(
    color: AppTheme.secondary.withValues(alpha: 0.7),
    width: 1.5,
  ),
);

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.stories,
    required this.completed,
    required this.memories,
  });

  final int stories;
  final int completed;
  final int memories;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Stat(value: stories, label: 'Stories'),
            ),
            _divider(),
            Expanded(
              child: _Stat(value: completed, label: 'Completed'),
            ),
            _divider(),
            Expanded(
              child: _Stat(value: memories, label: 'Memories'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => VerticalDivider(
    width: 1.5,
    thickness: 1.5,
    color: AppTheme.secondary.withValues(alpha: 0.7),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.error,
              ),
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MediumBreakdownCard extends StatelessWidget {
  const _MediumBreakdownCard({required this.rows, required this.total});

  final List<MapEntry<Medium, int>> rows;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stories by Medium',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
              child: Text(
                'Add a story to see your breakdown.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          for (final row in rows) ...[
            const SizedBox(height: AppTheme.spaceSm),
            _MediumRow(
              label: row.key.label,
              count: row.value,
              fraction: total == 0 ? 0 : row.value / total,
            ),
          ],
        ],
      ),
    );
  }
}

class _MediumRow extends StatelessWidget {
  const _MediumRow({
    required this.label,
    required this.count,
    required this.fraction,
  });

  final String label;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (fraction * 100).toStringAsFixed(2);
    return Semantics(
      label: '$label: $count stories, $percent percent',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
              Text('$count  ($percent%)', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXs),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: AppTheme.onSurface,
              valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
