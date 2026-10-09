import 'dart:math';

import '../models/memory.dart';

List<Memory> pickMemoriesOfTheDay(List<Memory> all, {DateTime? today}) {
  if (all.isEmpty) return const [];
  final now = today ?? DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;

  final byStory = <String, List<Memory>>{};
  for (final m in all) {
    byStory.putIfAbsent(m.storyId, () => []).add(m);
  }
  for (final list in byStory.values) {
    list.sort((a, b) => a.id.compareTo(b.id));
  }

  final storyIds = byStory.keys.toList()..sort();
  storyIds.shuffle(Random(seed));

  final picked = <Memory>[];
  for (var i = 0; i < storyIds.length && i < 2; i++) {
    final list = byStory[storyIds[i]]!;
    picked.add(list[Random(seed + i).nextInt(list.length)]);
  }

  if (picked.length == 1) {
    final rest = byStory[storyIds.first]!
        .where((m) => m.id != picked.first.id)
        .toList();
    if (rest.isNotEmpty) {
      picked.add(rest[Random(seed + 7).nextInt(rest.length)]);
    }
  }
  return picked;
}
