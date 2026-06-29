import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/content_item.dart';
import 'supabase_service.dart';

class ContentService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<List<ContentItem>> getContentItems({
    String? status,
    String? type,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (status != null) filters['status'] = status;
      if (type != null) filters['type'] = type;

      final data = await SupabaseService.fetchCached(
        table: 'exclusive_content',
        cacheKey: 'content_${status ?? "all"}_${type ?? "all"}_$search',
        select: '*, profiles:user_id(nombre)',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );

      List<ContentItem> items = data.map((json) {
        final profile = json.remove('profiles') as Map<String, dynamic>?;
        json['user_name'] = profile?['nombre'];
        return ContentItem.fromJson(json);
      }).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        items = items
            .where((item) =>
                item.title.toLowerCase().contains(q) ||
                (item.userName?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }

  static Future<ContentItem?> getContentItemById(String id) async {
    try {
      final data = await SupabaseService.fetchById(
        table: 'exclusive_content',
        id: id,
        select: '*, profiles:user_id(nombre)',
      );
      if (data == null) return null;
      final profile = data.remove('profiles') as Map<String, dynamic>?;
      data['user_name'] = profile?['nombre'];
      return ContentItem.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<ContentItem> approveContent(String id) async {
    try {
      final data = await SupabaseService.update(
        table: 'exclusive_content',
        id: id,
        data: {
          'status': 'approved',
          'reviewed_at': DateTime.now().toIso8601String(),
        },
      );
      return ContentItem.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<ContentItem> rejectContent(
      String id, String reason) async {
    try {
      final data = await SupabaseService.update(
        table: 'exclusive_content',
        id: id,
        data: {
          'status': 'rejected',
          'rejection_reason': reason,
          'reviewed_at': DateTime.now().toIso8601String(),
        },
      );
      return ContentItem.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteContent(String id) async {
    try {
      await SupabaseService.delete(table: 'exclusive_content', id: id);
    } catch (e) {
      rethrow;
    }
  }
}
