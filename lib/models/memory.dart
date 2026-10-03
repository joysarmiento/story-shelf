import 'story.dart';

enum EntryType { overallReview, chapter, episode, volume }

extension EntryTypeLabel on EntryType {
  String get label => switch (this) {
    EntryType.overallReview => 'Overall Review',
    EntryType.chapter => 'Chapter',
    EntryType.episode => 'Episode',
    EntryType.volume => 'Volume',
  };

  String get dbValue => name;

  static EntryType fromDb(String value) => EntryType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => EntryType.overallReview,
  );
}

class Memory {
  Memory({
    required this.id,
    required this.storyId,
    required this.entryType,
    this.progressReference,
    this.rating,
    this.title,
    required this.content,
    this.quote,
    required this.dateCreated,
    this.storyTitle,
    this.storyCoverPath,
    this.storyCreator,
    this.storyMedium,
  });

  final String id;
  final String storyId;
  final EntryType entryType;
  final String? progressReference;
  final double? rating;
  final String? title;
  final String content;
  final String? quote;
  final DateTime dateCreated;

  final String? storyTitle;
  final String? storyCoverPath;

  final String? storyCreator;
  final Medium? storyMedium;

  /// The memory's own title, or null when the user left it blank.
  String? get cleanTitle {
    final t = title?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['memory_id'] as String,
      storyId: json['story_id'] as String,
      entryType: EntryTypeLabel.fromDb(json['entry_type'] as String),
      progressReference: json['progress_reference'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      title: json['title'] as String?,
      content: json['content'] as String,
      quote: json['quote'] as String?,
      dateCreated: DateTime.parse(json['date_created'] as String),
      storyTitle: json['stories']?['title'] as String?,
      storyCoverPath: json['stories']?['cover_image_or_color'] as String?,
      storyCreator: json['stories']?['creator_author'] as String?,
      storyMedium: json['stories']?['medium'] != null
          ? MediumLabel.fromDb(json['stories']['medium'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'memory_id': id,
    'story_id': storyId,
    'entry_type': entryType.dbValue,
    'progress_reference': progressReference,
    'rating': rating,
    'title': title,
    'content': content,
    'quote': quote,
    'date_created': dateCreated.toIso8601String(),
  };
}
