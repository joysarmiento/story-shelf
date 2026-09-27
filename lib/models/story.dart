enum Medium { book, manhwa, manga, movie, drama, anime, tvSeries }

extension MediumLabel on Medium {
  String get label => switch (this) {
    Medium.book => 'Book',
    Medium.manhwa => 'Manhwa',
    Medium.manga => 'Manga',
    Medium.movie => 'Movie',
    Medium.drama => 'Drama',
    Medium.anime => 'Anime',
    Medium.tvSeries => 'TV Series',
  };

  /// Round-trips with the `medium` column in Supabase (stored as text).
  String get dbValue => name;

  static Medium fromDb(String value) => Medium.values.firstWhere(
    (m) => m.name == value,
    orElse: () => Medium.book,
  );
}

/// Library's status filter: Not Started / Started / Completed.
enum StoryStatus { notStarted, inProgress, completed }

extension StoryStatusLabel on StoryStatus {
  String get label => switch (this) {
    StoryStatus.notStarted => 'Not Started',
    StoryStatus.inProgress => 'Started',
    StoryStatus.completed => 'Completed',
  };

  String get dbValue => name;

  static StoryStatus fromDb(String value) => StoryStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => StoryStatus.notStarted,
  );
}

/// Mirrors the `stories` table (proposal Section F/I).
///
/// Column names below use the proposal's snake_case (story_id,
/// creator_author, ...) so fromJson/toJson can talk to Supabase directly
/// once that table exists.
class Story {
  Story({
    required this.id,
    required this.userId,
    required this.title,
    this.creator,
    this.releaseYear,
    required this.medium,
    this.coverPath,
    required this.status,
    this.currentProgress = 0,
    this.totalProgress,
    this.rating,
    this.isFavorite = false,
    this.overview,
    required this.dateAdded,
  });

  final String id;
  final String userId;
  final String title;
  final String? creator;
  final int? releaseYear;
  final Medium medium;

  /// A network/storage URL for the cover image. Null until Add Story's
  /// image picker (or a pasted URL) is wired up — StoryPosterCard falls
  /// back to a colored placeholder when this is null.
  final String? coverPath;

  final StoryStatus status;
  final double currentProgress;
  final double? totalProgress;

  /// 0-5. Null if the user hasn't rated it yet.
  final double? rating;
  final bool isFavorite;
  final String? overview;
  final DateTime dateAdded;

  /// 0.0-1.0, safe to feed straight into a progress bar.
  double get progressFraction {
    if (totalProgress == null || totalProgress == 0) return 0;
    return (currentProgress / totalProgress!).clamp(0, 1);
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['story_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      creator: json['creator_author'] as String?,
      releaseYear: json['release_year'] as int?,
      medium: MediumLabel.fromDb(json['medium'] as String),
      coverPath: json['cover_image_or_color'] as String?,
      status: StoryStatusLabel.fromDb(json['status'] as String),
      currentProgress: (json['current_progress'] as num?)?.toDouble() ?? 0,
      totalProgress: (json['total_progress'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      isFavorite: json['favorite'] as bool? ?? false,
      overview: json['overview'] as String?,
      dateAdded: DateTime.parse(json['date_added'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'story_id': id,
    'user_id': userId,
    'title': title,
    'creator_author': creator,
    'release_year': releaseYear,
    'medium': medium.dbValue,
    'cover_image_or_color': coverPath,
    'status': status.dbValue,
    'current_progress': currentProgress,
    'total_progress': totalProgress,
    'rating': rating,
    'favorite': isFavorite,
    'overview': overview,
    'date_added': dateAdded.toIso8601String(),
  };
}
