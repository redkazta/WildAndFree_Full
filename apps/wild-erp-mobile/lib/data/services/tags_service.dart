import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tag.dart';
import 'supabase_service.dart';

class TagsService {
  static SupabaseClient get _client => SupabaseService.client;

  // Categories
  static Future<List<TagCategory>> getCategories() async {
    try {
      final data = await SupabaseService.fetchCached(
        table: 'tag_categories',
        cacheKey: 'tag_categories',
        select: '*',
        orderBy: 'name',
      );
      return data.map((json) => TagCategory.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<TagCategory> createCategory(Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'tag_categories',
        data: data,
      );
      return TagCategory.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      await SupabaseService.delete(table: 'tag_categories', id: id);
    } catch (e) {
      rethrow;
    }
  }

  // Tags
  static Future<List<Tag>> getTags({
    String? categoryId,
    String? search,
    int limit = 100,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (categoryId != null) filters['category_id'] = categoryId;

      final data = await SupabaseService.fetchCached(
        table: 'tags',
        cacheKey: 'tags_${categoryId ?? "all"}_$search',
        select: '*, tag_categories:category_id(name)',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'name',
        limit: limit,
      );

      List<Tag> tags = data.map((json) {
        final category = json.remove('tag_categories') as Map<String, dynamic>?;
        json['category_name'] = category?['name'];
        return Tag.fromJson(json);
      }).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        tags = tags
            .where((t) => t.name.toLowerCase().contains(q))
            .toList();
      }

      return tags;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Tag> createTag(Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'tags',
        data: data,
      );
      return Tag.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Tag> updateTag(String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'tags',
        id: id,
        data: data,
      );
      return Tag.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteTag(String id) async {
    try {
      await SupabaseService.delete(table: 'tags', id: id);
    } catch (e) {
      rethrow;
    }
  }

  // User-tag assignment
  static Future<void> assignTagToUser(String userId, String tagId) async {
    try {
      await _client.from('user_tags').upsert({
        'user_id': userId,
        'tag_id': tagId,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeTagFromUser(String userId, String tagId) async {
    try {
      await _client
          .from('user_tags')
          .delete()
          .eq('user_id', userId)
          .eq('tag_id', tagId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> getUserTags(String userId) async {
    try {
      final data = await _client
          .from('user_tags')
          .select('tag_id')
          .eq('user_id', userId);
      return (data as List).map((e) => e['tag_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}
