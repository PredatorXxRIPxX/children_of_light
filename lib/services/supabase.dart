import 'dart:async';
import 'dart:core';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://jbmzvjfiwhqdbggqzeer.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpibXp2amZpd2hxZGJnZ3F6ZWVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU4Mzk4MjUsImV4cCI6MjA1MTQxNTgyNX0.2IiyXxHOk9otH9jilYcj2PZiKgefVQmkUDx9g0YOI0Q',
    );
    _client = Supabase.instance.client;
  }

  static void signOut() {
    _client = null;
  }

  static Future<dynamic> signIn(
      {required String email, required String password}) async {
    try {
      final auth = await client.auth.signUp(email: email,password: password);
      return auth;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> signUp(
      {required String username,
      required String email,
      required String password}) async {
    try {
      final AuthResponse res = await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (await _client!.from('users').select().eq('id', res.user!.id) != null ) {
        return false;
      }
      final auth = await _client!.from('users').insert(
        {
          'id': res.user!.id,
          'username': username,
          'email': email,
        }
      );
      return auth;
    } catch (e) {
      return false;
    }
  }
}
