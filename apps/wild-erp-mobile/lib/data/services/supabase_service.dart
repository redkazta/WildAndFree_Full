import 'package:supabase_flutter/supabase_flutter.dart';

import '../cache/cache_service.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // Generic fetch with cache
  static Future<List<Map<String, dynamic>>> fetchCached({
    required String table,
    String? cacheKey,
    String? select,
    String? filter,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    final key = cacheKey ?? _buildCacheKey(table, select, filter, filters, orderBy, ascending, limit);

    final cached = CacheService.get<List<Map<String, dynamic>>>(key);
    if (cached != null) return cached;

    try {
      PostgrestFilterBuilder query = _client.from(table).select(select ?? '*');

      if (filter != null) {
        query = query.filter(filter.contains('->'), '') as PostgrestFilterBuilder;
      }

      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            query = query.eq(entry.key, entry.value);
          }
        }
      }

      PostgrestTransformBuilder transform = query;

      if (orderBy != null) {
        transform = (query as PostgrestFilterBuilder).order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        transform = transform.limit(limit);
      }

      if (offset != null) {
        transform = transform.range(offset, offset + (limit ?? 50) - 1);
      }

      final data = await transform;
      final result = List<Map<String, dynamic>>.from(data);

      CacheService.set(key, result);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Generic single fetch
  static Future<Map<String, dynamic>?> fetchById({
    required String table,
    required String id,
    String? select,
  }) async {
    final key = '${table}_$id';
    final cached = CacheService.get<Map<String, dynamic>>(key);
    if (cached != null) return cached;

    try {
      final data = await _client
          .from(table)
          .select(select ?? '*')
          .eq('id', id)
          .maybeSingle();

      if (data != null) {
        CacheService.set(key, data);
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Generic insert
  static Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await _client.from(table).insert(data).select().single();
      CacheService.invalidatePattern(table);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Generic update
  static Future<Map<String, dynamic>> update({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await _client
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      CacheService.invalidatePattern(table);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Generic delete
  static Future<void> delete({
    required String table,
    required String id,
  }) async {
    try {
      await _client.from(table).delete().eq('id', id);
      CacheService.invalidatePattern(table);
    } catch (e) {
      rethrow;
    }
  }

  // RPC call
  static Future<dynamic> rpc({
    required String function,
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _client.rpc(function, params: params);
    } catch (e) {
      rethrow;
    }
  }

  static String _buildCacheKey(
    String table,
    String? select,
    String? filter,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending,
    int? limit,
  ) {
    final parts = [table];
    if (select != null) parts.add('s:$select');
    if (filter != null) parts.add('f:$filter');
    if (filters != null) {
      final sorted = filters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (final e in sorted) {
        parts.add('${e.key}=${e.value}');
      }
    }
    if (orderBy != null) parts.add('o:$orderBy:${ascending ? "asc" : "desc"}');
    if (limit != null) parts.add('l:$limit');
    return parts.join('|');
  }
}
