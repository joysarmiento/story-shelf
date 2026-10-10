import 'story.dart';

class StorySearchResult {
  const StorySearchResult({
    required this.title,
    required this.medium,
    this.externalId,
    this.creator,
    this.year,
    this.coverUrl,
    this.totalProgress,
  });

  final String title;
  final Medium medium;
  final String? externalId;
  final String? creator;
  final int? year;
  final String? coverUrl;
  final double? totalProgress;

  String get shelfKey => shelfKeyFor(title, medium);

  static String shelfKeyFor(String title, Medium m) =>
      '${m.name}|${title.trim().toLowerCase()}';

  StorySearchResult copyWith({String? creator, double? totalProgress}) {
    return StorySearchResult(
      title: title,
      medium: medium,
      externalId: externalId,
      creator: creator ?? this.creator,
      year: year,
      coverUrl: coverUrl,
      totalProgress: totalProgress ?? this.totalProgress,
    );
  }
}
