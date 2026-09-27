import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/memory.dart';
import '../models/story.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    if (response.user == null) {
      throw const AuthException('Sign up failed. Please try again.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<List<Story>> getStoriesForUser() async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('stories')
        .select()
        .eq('user_id', userId)
        .order('date_added');
    return (rows as List)
        .map((row) => Story.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addStory(Story story) async {
    await _client.from('stories').insert(story.toJson());
  }

  Future<void> updateStory(Story story) async {
    await _client
        .from('stories')
        .update(story.toJson())
        .eq('story_id', story.id);
  }

  Future<void> deleteStory(String storyId) async {
    await _client.from('stories').delete().eq('story_id', storyId);
  }

  Future<List<Memory>> getMemoriesForStory(String storyId) async {
    final rows = await _client
        .from('memories')
        .select(
          '*, stories(title, cover_image_or_color, creator_author, medium)',
        )
        .eq('story_id', storyId)
        .order('date_created', ascending: false);
    return (rows as List)
        .map((row) => Memory.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
