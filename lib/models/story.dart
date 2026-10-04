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

  String get progressUnitLabel => switch (this) {
    Medium.book => 'Page',
    Medium.manhwa || Medium.manga => 'Chapter',
    Medium.movie => 'Part',
    Medium.drama || Medium.tvSeries || Medium.anime => 'Episode',
  };

  String get dbValue => name;

  static Medium fromDb(String value) => Medium.values.firstWhere(
    (m) => m.name == value,
    orElse: () => Medium.book,
  );
}

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
    this.lastReadAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? creator;
  final int? releaseYear;
  final Medium medium;

  final String? coverPath;

  final StoryStatus status;
  final double currentProgress;
  final double? totalProgress;

  final double? rating;
  final bool isFavorite;
  final String? overview;
  final DateTime dateAdded;
  final DateTime? lastReadAt;

  double get progressFraction {
    if (totalProgress == null || totalProgress == 0) return 0;
    return (currentProgress / totalProgress!).clamp(0, 1);
  }

  Story copyWith({
    String? title,
    String? creator,
    int? releaseYear,
    Medium? medium,
    String? coverPath,
    StoryStatus? status,
    double? currentProgress,
    double? totalProgress,
    double? rating,
    bool? isFavorite,
    String? overview,
    DateTime? lastReadAt,
  }) {
    return Story(
      id: id,
      userId: userId,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      releaseYear: releaseYear ?? this.releaseYear,
      medium: medium ?? this.medium,
      coverPath: coverPath ?? this.coverPath,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      overview: overview ?? this.overview,
      dateAdded: dateAdded,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
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
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
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
    'last_read_at': lastReadAt?.toIso8601String(),
  };
}
