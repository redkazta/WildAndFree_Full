import 'package:supabase_flutter/supabase_flutter.dart';

import '../cache/cache_service.dart';
import 'supabase_service.dart';

class DashboardStats {
  final int totalUsers;
  final int totalArtists;
  final int pendingOrders;
  final int pendingContent;
  final int totalTokens;
  final int totalEvents;
  final int totalProducts;
  final int totalRevenue;

  DashboardStats({
    this.totalUsers = 0,
    this.totalArtists = 0,
    this.pendingOrders = 0,
    this.pendingContent = 0,
    this.totalTokens = 0,
    this.totalEvents = 0,
    this.totalProducts = 0,
    this.totalRevenue = 0,
  });
}

class DashboardService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<DashboardStats> getStats() async {
    const cacheKey = 'dashboard_stats';
    final cached = CacheService.get<DashboardStats>(cacheKey);
    if (cached != null) return cached;

    try {
      final results = await Future.wait([
        _countTable('profiles'),
        _countTable('profiles', filter: 'is_artist', value: true),
        _countTable('store_orders', filter: 'status', value: 'pending'),
        _countTable('exclusive_content', filter: 'status', value: 'pending'),
        _countTable('events'),
        _countTable('store_products'),
        _getTotalTokens(),
        _getTotalRevenue(),
      ]);

      final stats = DashboardStats(
        totalUsers: results[0] as int,
        totalArtists: results[1] as int,
        pendingOrders: results[2] as int,
        pendingContent: results[3] as int,
        totalEvents: results[4] as int,
        totalProducts: results[5] as int,
        totalTokens: results[6] as int,
        totalRevenue: results[7] as int,
      );

      CacheService.set(cacheKey, stats);
      return stats;
    } catch (e) {
      return DashboardStats();
    }
  }

  static Future<int> _countTable(
    String table, {
    String? filter,
    dynamic value,
  }) async {
    try {
      PostgrestFilterBuilder query = _client.from(table).select('id');
      if (filter != null && value != null) {
        query = query.eq(filter, value);
      }
      final data = await query;
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> _getTotalTokens() async {
    try {
      final data = await _client
          .from('user_tokens')
          .select('balance');
      final list = data as List;
      return list.fold<int>(0, (sum, e) => sum + ((e['balance'] as int?) ?? 0));
    } catch (e) {
      return 0;
    }
  }

  static Future<int> _getTotalRevenue() async {
    try {
      final data = await _client
          .from('store_orders')
          .select('total');
      final list = data as List;
      return list.fold<int>(
          0, (sum, e) => sum + ((e['total'] as int?) ?? 0));
    } catch (e) {
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentActivity({
    int limit = 10,
  }) async {
    try {
      final data = await _client
          .from('activity_log')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }
}
