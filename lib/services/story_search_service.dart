import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/story.dart';
import '../models/story_search_result.dart';

class StorySearchService {
  StorySearchService._();
  static final instance = StorySearchService._();

  static const _timeout = Duration(seconds: 10);

  String get _tmdbKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key == null || key.isEmpty) throw Exception('Search is not set up.');
    return key;
  }

  Future<dynamic> _getJson(Uri uri) async {
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Search failed (${res.statusCode}).');
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> _anilist(String query, Map<String, dynamic> variables) async {
    final res = await http
        .post(
          Uri.https('graphql.anilist.co', '/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'query': query, 'variables': variables}),
        )
        .timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Search failed (${res.statusCode}).');
    }
    return jsonDecode(res.body);
  }

  Future<List<StorySearchResult>> search(String q, Medium medium) =>
      switch (medium) {
        Medium.book => _books(q),
        Medium.comic => _comics(q),
        Medium.movie => _tmdb(q, movie: true),
        Medium.series => _tmdb(q, movie: false),
      };

  Future<List<StorySearchResult>> _books(String q) async {
    final json = await _getJson(
      Uri.https('openlibrary.org', '/search.json', {
        'q': q,
        'limit': '20',
        'fields':
            'title,author_name,first_publish_year,cover_i,number_of_pages_median',
      }),
    );
    final docs = (json['docs'] as List?) ?? const [];
    return docs
        .map<StorySearchResult>((d) {
          final authors = d['author_name'] as List?;
          final cover = d['cover_i'];
          return StorySearchResult(
            title: (d['title'] as String?) ?? '',
            medium: Medium.book,
            creator: (authors != null && authors.isNotEmpty)
                ? authors.first as String
                : null,
            year: d['first_publish_year'] as int?,
            coverUrl: cover == null
                ? null
                : 'https://covers.openlibrary.org/b/id/$cover-L.jpg',
            totalProgress: (d['number_of_pages_median'] as num?)?.toDouble(),
          );
        })
        .where((r) => r.title.isNotEmpty)
        .toList();
  }

  Future<List<StorySearchResult>> _tmdb(String q, {required bool movie}) async {
    final json = await _getJson(
      Uri.https(
        'api.themoviedb.org',
        movie ? '/3/search/movie' : '/3/search/tv',
        {'api_key': _tmdbKey, 'query': q},
      ),
    );
    final results = (json['results'] as List?) ?? const [];
    return results
        .map<StorySearchResult>((r) {
          final date =
              (r[movie ? 'release_date' : 'first_air_date'] as String?) ?? '';
          final poster = r['poster_path'] as String?;
          return StorySearchResult(
            title: ((movie ? r['title'] : r['name']) as String?) ?? '',
            medium: movie ? Medium.movie : Medium.series,
            externalId: r['id']?.toString(),
            year: date.length >= 4 ? int.tryParse(date.substring(0, 4)) : null,
            coverUrl: poster == null
                ? null
                : 'https://image.tmdb.org/t/p/w500$poster',
          );
        })
        .where((r) => r.title.isNotEmpty)
        .toList();
  }

  Future<List<StorySearchResult>> _comics(String q) async {
    const gql = r'''
      query($q: String) {
        Page(perPage: 20) {
          media(search: $q, type: MANGA) {
            id
            title { romaji english }
            startDate { year }
            chapters
            coverImage { large }
          }
        }
      }''';
    final json = await _anilist(gql, {'q': q});
    final media = (json['data']?['Page']?['media'] as List?) ?? const [];
    return media
        .map<StorySearchResult>((m) {
          final t = (m['title'] as Map?) ?? const {};
          return StorySearchResult(
            title: ((t['english'] ?? t['romaji']) as String?) ?? '',
            medium: Medium.comic,
            externalId: m['id']?.toString(),
            year: m['startDate']?['year'] as int?,
            coverUrl: m['coverImage']?['large'] as String?,
            totalProgress: (m['chapters'] as num?)?.toDouble(),
          );
        })
        .where((r) => r.title.isNotEmpty)
        .toList();
  }

  Future<StorySearchResult> withDetails(StorySearchResult r) async {
    try {
      return switch (r.medium) {
        Medium.book => r,
        Medium.comic => await _comicDetails(r),
        Medium.movie => await _movieDetails(r),
        Medium.series => await _seriesDetails(r),
      };
    } catch (_) {
      return r;
    }
  }

  Future<StorySearchResult> _movieDetails(StorySearchResult r) async {
    final id = r.externalId;
    if (id == null) return r;
    final json = await _getJson(
      Uri.https('api.themoviedb.org', '/3/movie/$id', {
        'api_key': _tmdbKey,
        'append_to_response': 'credits',
      }),
    );
    final crew = (json['credits']?['crew'] as List?) ?? const [];
    final directors = crew
        .where((c) => c['job'] == 'Director')
        .map((c) => c['name'] as String)
        .toList();
    return r.copyWith(creator: directors.isEmpty ? null : directors.join(', '));
  }

  Future<StorySearchResult> _seriesDetails(StorySearchResult r) async {
    final id = r.externalId;
    if (id == null) return r;
    final json = await _getJson(
      Uri.https('api.themoviedb.org', '/3/tv/$id', {'api_key': _tmdbKey}),
    );
    final creators = ((json['created_by'] as List?) ?? const [])
        .map((c) => c['name'] as String)
        .toList();
    final networks = ((json['networks'] as List?) ?? const [])
        .map((n) => n['name'] as String)
        .toList();
    final creator = creators.isNotEmpty
        ? creators.join(', ')
        : (networks.isNotEmpty ? networks.first : null);
    final episodes = (json['number_of_episodes'] as num?)?.toDouble();
    return r.copyWith(
      creator: creator,
      totalProgress: (episodes != null && episodes > 0) ? episodes : null,
    );
  }

  Future<StorySearchResult> _comicDetails(StorySearchResult r) async {
    final id = int.tryParse(r.externalId ?? '');
    if (id == null) return r;
    const gql = r'''
      query($id: Int) {
        Media(id: $id, type: MANGA) {
          staff(perPage: 8) { edges { role node { name { full } } } }
        }
      }''';
    final json = await _anilist(gql, {'id': id});
    final edges =
        (json['data']?['Media']?['staff']?['edges'] as List?) ?? const [];

    final authors = <String>[];
    for (final e in edges) {
      final role = ((e['role'] as String?) ?? '').toLowerCase();
      final name = e['node']?['name']?['full'] as String?;
      if (name != null &&
          (role.contains('story') || role.contains('original'))) {
        authors.add(name);
      }
    }
    if (authors.isEmpty && edges.isNotEmpty) {
      final name = edges.first['node']?['name']?['full'] as String?;
      if (name != null) authors.add(name);
    }
    return r.copyWith(creator: authors.isEmpty ? null : authors.join(', '));
  }
}
