import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';

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
    applyPreferences();
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    // Preferences belong to the account, so reset them on the way out.
    AppTheme.setHighContrast(false);
    AppTheme.setTextSize(TextSize.medium);
  }

  // Preferences

  bool get highContrastPref => _meta['high_contrast'] == true;

  TextSize get textSizePref => TextSize.values.firstWhere(
    (t) => t.name == _meta['text_size'],
    orElse: () => TextSize.medium,
  );

  void applyPreferences() {
    AppTheme.setHighContrast(highContrastPref);
    AppTheme.setTextSize(textSizePref);
  }

  Future<void> saveTextSize(TextSize value) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'text_size': value.name}),
    );
  }

  Future<void> saveHighContrast(bool value) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'high_contrast': value}),
    );
  }

  // Profile
  Map<String, dynamic> get _meta => currentUser?.userMetadata ?? const {};

  String? get email => currentUser?.email;

  String get displayName {
    final name = (_meta['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email?.split('@').first ?? 'Story Shelf reader';
  }

  String get username {
    final u = (_meta['username'] as String?)?.trim();
    if (u != null && u.isNotEmpty) return u;
    return email?.split('@').first ?? 'reader';
  }

  String? get avatarUrl {
    final a = (_meta['avatar_url'] as String?)?.trim();
    return (a == null || a.isEmpty) ? null : a;
  }

  Future<bool> updateProfile({
    required String name,
    required String username,
    required String email,
    String? avatarUrl,
  }) async {
    final emailChanged = email != currentUser?.email;
    await _client.auth.updateUser(
      UserAttributes(
        email: emailChanged ? email : null,
        data: {'name': name, 'username': username, 'avatar_url': avatarUrl},
      ),
    );
    return emailChanged;
  }

  /// Deleting an auth user can't be done from the client with the publishable
  /// key, so this calls a database function. Create it once in the Supabase
  /// SQL editor (and make sure your tables use ON DELETE CASCADE):
  ///
  ///   create or replace function public.delete_user()
  ///   returns void language sql security definer
  ///   set search_path = public, auth as $$
  ///     delete from auth.users where id = auth.uid();
  ///   $$;
  ///   grant execute on function public.delete_user() to authenticated;
  Future<void> deleteAccount() async {
    await _client.rpc('delete_user');
    await signOut();
  }

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

  Future<List<Memory>> getAllMemoriesForUser() async {
    final rows = await _client
        .from('memories')
        .select(
          '*, stories(title, cover_image_or_color, creator_author, medium)',
        )
        .order('date_created', ascending: false);
    return (rows as List)
        .map((r) => Memory.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMemory(Memory m) async {
    await _client.from('memories').insert(m.toJson());
  }

  Future<void> updateMemory(Memory m) async {
    await _client.from('memories').update(m.toJson()).eq('memory_id', m.id);
  }

  Future<void> deleteMemory(String memoryId) async {
    await _client.from('memories').delete().eq('memory_id', memoryId);
  }

  Future<Story?> getStory(String storyId) async {
    final row = await _client
        .from('stories')
        .select()
        .eq('story_id', storyId)
        .maybeSingle();
    return row == null ? null : Story.fromJson(row);
  }

  Future<Memory?> getMemory(String memoryId) async {
    final row = await _client
        .from('memories')
        .select(
          '*, stories(title, cover_image_or_color, creator_author, medium)',
        )
        .eq('memory_id', memoryId)
        .maybeSingle();
    return row == null ? null : Memory.fromJson(row);
  }
}
