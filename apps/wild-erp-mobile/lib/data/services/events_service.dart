import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event.dart';
import 'supabase_service.dart';

class EventsService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<List<Event>> getEvents({
    String? type,
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (type != null) filters['event_type'] = type;
      if (isActive != null) filters['is_active'] = isActive;

      final data = await SupabaseService.fetchCached(
        table: 'events',
        cacheKey: 'events_${type ?? "all"}_${isActive ?? "all"}',
        select: '*',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'event_date',
        ascending: true,
        limit: limit,
        offset: offset,
      );

      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Event?> getEventById(String id) async {
    try {
      final data = await SupabaseService.fetchById(
        table: 'events',
        id: id,
      );
      if (data == null) return null;
      return Event.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Event> createEvent(Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'events',
        data: data,
      );
      return Event.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Event> updateEvent(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'events',
        id: id,
        data: data,
      );
      return Event.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteEvent(String id) async {
    try {
      await SupabaseService.delete(table: 'events', id: id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> getEventCount() async {
    try {
      final data = await SupabaseService.fetchCached(
        table: 'events',
        cacheKey: 'event_count',
        select: 'id',
        limit: 99999,
      );
      return data.length;
    } catch (e) {
      return 0;
    }
  }
}
