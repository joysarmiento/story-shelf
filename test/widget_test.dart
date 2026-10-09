import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:final_project/models/memory.dart';
import 'package:final_project/models/story.dart';
import 'package:final_project/utils/error_message.dart';
import 'package:final_project/utils/memory_of_the_day.dart';
import 'package:final_project/widgets/primary_button.dart';

Story _story({double current = 0, double? total, double? rating}) => Story(
  id: 's1',
  userId: 'u1',
  title: 'Howl\'s Moving Castle',
  medium: Medium.book,
  status: StoryStatus.inProgress,
  currentProgress: current,
  totalProgress: total,
  rating: rating,
  dateAdded: DateTime(2026, 1, 1),
);

Memory _memory(String id, String storyId) => Memory(
  id: id,
  storyId: storyId,
  entryType: EntryType.overallReview,
  content: 'It made me cry.',
  dateCreated: DateTime(2026, 1, 1),
);

void main() {
  group('Story', () {
    test('progressFraction is current / total', () {
      expect(_story(current: 5, total: 10).progressFraction, 0.5);
    });

    test('progressFraction is 0 when there is no total', () {
      expect(_story(current: 5).progressFraction, 0);
      expect(_story(current: 5, total: 0).progressFraction, 0);
    });

    test('progressFraction never goes above 1', () {
      expect(_story(current: 12, total: 10).progressFraction, 1);
    });

    test('toJson then fromJson keeps every field', () {
      final original = _story(current: 3, total: 12, rating: 4.5);
      final copy = Story.fromJson(original.toJson());

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.medium, Medium.book);
      expect(copy.status, StoryStatus.inProgress);
      expect(copy.currentProgress, 3);
      expect(copy.totalProgress, 12);
      expect(copy.rating, 4.5);
      expect(copy.dateAdded, original.dateAdded);
    });

    test('copyWith changes only what it is given', () {
      final updated = _story(current: 1, total: 4).copyWith(isFavorite: true);

      expect(updated.isFavorite, isTrue);
      expect(updated.title, 'Howl\'s Moving Castle');
      expect(updated.currentProgress, 1);
    });
  });

  group('Medium and StoryStatus', () {
    test('fromDb reads a saved value and falls back safely', () {
      expect(MediumLabel.fromDb('comic'), Medium.comic);
      expect(MediumLabel.fromDb('series'), Medium.series);
      expect(MediumLabel.fromDb('not-a-medium'), Medium.book);
      expect(StoryStatusLabel.fromDb('completed'), StoryStatus.completed);
      expect(StoryStatusLabel.fromDb('???'), StoryStatus.notStarted);
    });

    test('stories saved with the old, specific types still load', () {
      expect(MediumLabel.fromDb('manga'), Medium.comic);
      expect(MediumLabel.fromDb('manhwa'), Medium.comic);
      expect(MediumLabel.fromDb('drama'), Medium.series);
      expect(MediumLabel.fromDb('anime'), Medium.series);
      expect(MediumLabel.fromDb('tvSeries'), Medium.series);
      expect(MediumLabel.fromDb('movie'), Medium.movie);
      expect(MediumLabel.fromDb('book'), Medium.book);
    });

    test('the progress label matches the medium', () {
      expect(Medium.book.progressUnitLabel, 'Page');
      expect(Medium.comic.progressUnitLabel, 'Chapter');
      expect(Medium.movie.progressUnitLabel, 'Part');
      expect(Medium.series.progressUnitLabel, 'Episode');
    });

    test('each medium has a short label', () {
      expect(Medium.values.map((m) => m.label), [
        'Book',
        'Comic',
        'Movie',
        'Series',
      ]);
    });

    test('search words let "manga" find a Comic and "anime" find a Series', () {
      expect(Medium.comic.searchWords, contains('manga'));
      expect(Medium.series.searchWords, contains('anime'));
      expect(Medium.movie.searchWords, contains('film'));
      expect(Medium.book.searchWords, contains('novel'));
    });
  });

  group('Memory', () {
    test('fromJson reads the joined story fields', () {
      final memory = Memory.fromJson({
        'memory_id': 'm1',
        'story_id': 's1',
        'entry_type': 'episode',
        'progress_reference': 'Episode 3',
        'rating': 5,
        'title': 'The ending',
        'content': 'Wow.',
        'quote': null,
        'date_created': '2026-02-03T10:00:00.000',
        'stories': {
          'title': 'Frieren',
          'cover_image_or_color': null,
          'creator_author': 'Kanehito Yamada',
          'medium': 'anime',
        },
      });

      expect(memory.entryType, EntryType.episode);
      expect(memory.rating, 5.0);
      expect(memory.storyTitle, 'Frieren');
      expect(memory.storyMedium, Medium.series);
    });

    test('cleanTitle hides blank titles', () {
      final blank = Memory(
        id: 'm',
        storyId: 's',
        entryType: EntryType.overallReview,
        title: '   ',
        content: 'x',
        dateCreated: DateTime(2026, 1, 1),
      );
      expect(blank.cleanTitle, isNull);
      expect(_memory('m', 's').cleanTitle, isNull);
    });
  });

  group('pickMemoriesOfTheDay', () {
    final day = DateTime(2026, 10, 10);

    test('returns nothing when there are no memories', () {
      expect(pickMemoriesOfTheDay([], today: day), isEmpty);
    });

    test('returns the only memory when there is just one', () {
      final picked = pickMemoriesOfTheDay([_memory('a', 's1')], today: day);
      expect(picked.map((m) => m.id), ['a']);
    });

    test('picks two different stories when it can', () {
      final picked = pickMemoriesOfTheDay([
        _memory('a', 's1'),
        _memory('b', 's2'),
        _memory('c', 's3'),
      ], today: day);

      expect(picked, hasLength(2));
      expect(picked[0].storyId, isNot(picked[1].storyId));
    });

    test('uses two different memories when there is only one story', () {
      final picked = pickMemoriesOfTheDay([
        _memory('a', 's1'),
        _memory('b', 's1'),
        _memory('c', 's1'),
      ], today: day);

      expect(picked, hasLength(2));
      expect(picked[0].id, isNot(picked[1].id));
    });

    test('gives the same answer all day', () {
      final all = [for (var i = 0; i < 8; i++) _memory('m$i', 's${i % 4}')];

      final first = pickMemoriesOfTheDay(all, today: day);
      final second = pickMemoriesOfTheDay(all, today: day);
      expect(first.map((m) => m.id), second.map((m) => m.id));
    });
  });

  group('friendlyError', () {
    test('explains a wrong password', () {
      final text = friendlyError(
        const AuthException('Invalid login credentials', statusCode: '400'),
      );
      expect(text, 'Wrong email or password.');
    });

    test('explains an unconfirmed email', () {
      final text = friendlyError(
        const AuthException('Email not confirmed', statusCode: '400'),
      );
      expect(text, contains('confirm your email'));
    });

    test('explains an email that is already used', () {
      final text = friendlyError(
        const AuthException('User already registered', statusCode: '422'),
      );
      expect(text, contains('already exists'));
    });

    test('explains too many attempts', () {
      final text = friendlyError(
        const AuthException('Email rate limit exceeded', statusCode: '429'),
      );
      expect(text, contains('Too many attempts'));
    });

    test('keeps a message the app wrote itself', () {
      final text = friendlyError(
        const AuthException('Sign up failed. Please try again.'),
      );
      expect(text, 'Sign up failed. Please try again.');
    });

    test('hides unknown account errors behind a friendly sentence', () {
      final text = friendlyError(
        const AuthException('internal gremlin 0x42', statusCode: '500'),
      );
      expect(text, isNot(contains('gremlin')));
      expect(text, contains('Something went wrong'));
    });

    test('explains a database permission error', () {
      final text = friendlyError(
        PostgrestException(
          message: 'new row violates row-level security policy',
          code: '42501',
        ),
      );
      expect(text, "You don't have permission to do that.");
    });

    test('explains being offline', () {
      final text = friendlyError(Exception('ClientException: Failed to fetch'));
      expect(text, contains('internet'));
    });

    test('never shows the raw exception text', () {
      final text = friendlyError(Exception('boom'));
      expect(text, 'Something went wrong. Please try again.');
      expect(text, isNot(contains('Exception')));
    });
  });

  group('PrimaryButton', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required VoidCallback onPressed,
      bool isLoading = false,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Open My Shelf',
              isLoading: isLoading,
              onPressed: onPressed,
            ),
          ),
        ),
      );
    }

    testWidgets('shows its label and runs onPressed when tapped', (
      tester,
    ) async {
      var taps = 0;
      await pumpButton(tester, onPressed: () => taps++);

      expect(find.text('Open My Shelf'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(milliseconds: 300));

      expect(taps, 1);
    });

    testWidgets('shows a spinner and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await pumpButton(tester, onPressed: () => taps++, isLoading: true);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Open My Shelf'), findsNothing);

      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(milliseconds: 300));

      expect(taps, 0);
    });
  });
}
