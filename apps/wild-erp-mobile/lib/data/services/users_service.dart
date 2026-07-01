import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import 'supabase_service.dart';

class UsersService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<List<Profile>> getUsers({
    String? role,
    String? search,
    bool? isArtist,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (role != null) filters['role'] = role;
      if (isArtist != null) filters['is_artist'] = isArtist;

      final data = await SupabaseService.fetchCached(
        table: 'profiles',
        cacheKey: 'users_${role ?? "all"}_${isArtist ?? "all"}_$search',
        select: '*',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );

      List<Profile> users =
          data.map((json) => Profile.fromJson(json)).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        users = users
            .where((u) =>
                (u.displayName?.toLowerCase().contains(q) ?? false) ||
                (u.email?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      return users;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Profile?> getUserById(String id) async {
    try {
      final data = await SupabaseService.fetchById(
        table: 'profiles',
        id: id,
      );
      if (data == null) return null;
      return Profile.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Profile> updateUser(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'profiles',
        id: id,
        data: data,
      );
      return Profile.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUserRole(String id, String role) async {
    try {
      await SupabaseService.update(
        table: 'profiles',
        id: id,
        data: {'role': role},
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleArtistStatus(String id, bool isArtist) async {
    try {
      await SupabaseService.update(
        table: 'profiles',
        id: id,
        data: {'is_artist': isArtist},
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleVerification(String id, bool isVerified) async {
    try {
      await SupabaseService.update(
        table: 'profiles',
        id: id,
        data: {'is_verified': isVerified},
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> assignTokens(String id, int tokens) async {
    try {
      final user = await getUserById(id);
      if (user == null) throw Exception('User not found');

      await SupabaseService.update(
        table: 'profiles',
        id: id,
        data: {'tokens': user.tokens + tokens},
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> getUserCount({String? role}) async {
    try {
      final filters = <String, dynamic>{};
      if (role != null) filters['role'] = role;

      final data = await SupabaseService.fetchCached(
        table: 'profiles',
        cacheKey: 'user_count_${role ?? "all"}',
        select: 'id',
        filters: filters.isNotEmpty ? filters : null,
        limit: 99999,
      );
      return data.length;
    } catch (e) {
      return 0;
    }
  }
}
