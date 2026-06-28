import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/freestyler.dart';
import 'supabase_service.dart';

class VersusService {
  static SupabaseClient get _client => SupabaseService.client;

  // Freestylers
  static Future<List<Freestyler>> getFreestylers({
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (isActive != null) filters['is_active'] = isActive;

      final data = await SupabaseService.fetchCached(
        table: 'freestylers',
        cacheKey: 'freestylers_${isActive ?? "all"}',
        select: '*',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'elo_rating',
        ascending: false,
        limit: limit,
        offset: offset,
      );

      return data.map((json) => Freestyler.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Freestyler?> getFreestylerById(String id) async {
    try {
      final data = await SupabaseService.fetchById(
        table: 'freestylers',
        id: id,
      );
      if (data == null) return null;
      return Freestyler.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Freestyler> createFreestyler(
      Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'freestylers',
        data: data,
      );
      return Freestyler.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Freestyler> updateFreestyler(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'freestylers',
        id: id,
        data: data,
      );
      return Freestyler.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteFreestyler(String id) async {
    try {
      await SupabaseService.delete(table: 'freestylers', id: id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateStatSliders(
      String id, Map<String, double> sliders) async {
    try {
      await SupabaseService.update(
        table: 'freestylers',
        id: id,
        data: {'stat_sliders': sliders},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Battles
  static Future<List<Battle>> getBattles({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final data = await SupabaseService.fetchCached(
        table: 'battles',
        cacheKey: 'battles',
        select: '*',
        orderBy: 'battle_date',
        ascending: false,
        limit: limit,
        offset: offset,
      );

      return data.map((json) => Battle.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Battle> createBattle(Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'battles',
        data: data,
      );
      return Battle.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Battle> updateBattle(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'battles',
        id: id,
        data: data,
      );
      return Battle.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteBattle(String id) async {
    try {
      await SupabaseService.delete(table: 'battles', id: id);
    } catch (e) {
      rethrow;
    }
  }
}
