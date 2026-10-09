import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String friendlyError(Object error) {
  if (kDebugMode) debugPrint('Error: $error');

  if (_looksOffline(error.toString().toLowerCase())) {
    return 'No internet connection. Please check it and try again.';
  }
  if (error is AuthException) return _authMessage(error);
  if (error is PostgrestException) return _databaseMessage(error);
  if (error is StorageException) return _storageMessage(error);
  return 'Something went wrong. Please try again.';
}

bool _looksOffline(String raw) {
  const hints = [
    'socketexception',
    'failed to fetch',
    'xmlhttprequest',
    'failed host lookup',
    'network is unreachable',
    'connection refused',
    'connection closed',
    'connection reset',
    'timeoutexception',
    'clientexception',
  ];
  return hints.any(raw.contains);
}

String _authMessage(AuthException e) {
  final msg = e.message.toLowerCase();

  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid credentials')) {
    return 'Wrong email or password.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Please confirm your email first. Check your inbox for the link.';
  }
  if (msg.contains('already registered') ||
      msg.contains('already been registered')) {
    return 'An account with this email already exists. Try logging in.';
  }
  if (msg.contains('weak') || msg.contains('password should be')) {
    return 'Please choose a stronger password.';
  }
  if (msg.contains('rate limit') ||
      msg.contains('too many') ||
      e.statusCode == '429') {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (msg.contains('invalid email') ||
      msg.contains('unable to validate email')) {
    return "That email address doesn't look right.";
  }
  if (msg.contains('jwt') ||
      msg.contains('session') ||
      msg.contains('not authenticated')) {
    return 'Your session has expired. Please log in again.';
  }
  if (e.statusCode == null) return e.message;
  return 'Something went wrong with your account. Please try again.';
}

String _databaseMessage(PostgrestException e) {
  final msg = e.message.toLowerCase();

  if (e.code == '42501' ||
      msg.contains('row-level security') ||
      msg.contains('permission denied')) {
    return "You don't have permission to do that.";
  }
  if (e.code == '23505') return 'That already exists.';
  if (e.code == '23503') {
    return 'That is linked to something that no longer exists. '
        'Please refresh and try again.';
  }
  if (e.code == '23502' || e.code == '22P02' || e.code == '22001') {
    return 'Some of the information looks invalid. '
        'Please check it and try again.';
  }
  if (e.code == 'PGRST116') {
    return "We couldn't find that. It may have been deleted.";
  }
  if (e.code == 'PGRST301' || msg.contains('jwt')) {
    return 'Your session has expired. Please log in again.';
  }
  return 'Something went wrong with your data. Please try again.';
}

String _storageMessage(StorageException e) {
  final msg = e.message.toLowerCase();

  if (e.statusCode == '413' ||
      msg.contains('too large') ||
      msg.contains('exceeded')) {
    return 'That image is too large. Try a smaller one.';
  }
  if (e.statusCode == '403' ||
      msg.contains('row-level security') ||
      msg.contains('unauthorized')) {
    return "You don't have permission to upload that.";
  }
  if (msg.contains('mime') || msg.contains('not supported')) {
    return 'That file type is not supported. Use a JPG, PNG or WebP image.';
  }
  return 'The image could not be uploaded. Please try again.';
}
