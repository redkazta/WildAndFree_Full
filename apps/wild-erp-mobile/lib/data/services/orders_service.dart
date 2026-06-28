import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../cache/cache_service.dart';
import 'supabase_service.dart';

class OrdersService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<List<Order>> getOrders({
    String? status,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final data = await SupabaseService.fetchCached(
        table: 'orders',
        cacheKey: 'orders_${status ?? "all"}_$search',
        select: '*, profiles:user_id(display_name, email)',
        filters: status != null ? {'status': status} : null,
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );

      return data.map((json) {
        final profile = json.remove('profiles') as Map<String, dynamic>?;
        json['user_name'] = profile?['display_name'];
        json['user_email'] = profile?['email'];
        return Order.fromJson(json);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Order?> getOrderById(String id) async {
    try {
      final data = await SupabaseService.fetchById(
        table: 'orders',
        id: id,
        select: '*, profiles:user_id(display_name, email)',
      );
      if (data == null) return null;
      final profile = data.remove('profiles') as Map<String, dynamic>?;
      data['user_name'] = profile?['display_name'];
      data['user_email'] = profile?['email'];
      return Order.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Order> updateOrderStatus(String id, String status) async {
    try {
      final data = await SupabaseService.update(
        table: 'orders',
        id: id,
        data: {'status': status},
      );
      return Order.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Order> updateOrder(String id, Map<String, dynamic> updates) async {
    try {
      final data = await SupabaseService.update(
        table: 'orders',
        id: id,
        data: updates,
      );
      return Order.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> getOrderCount({String? status}) async {
    try {
      final data = await SupabaseService.rpc(
        function: 'count_orders',
        params: status != null ? {'p_status': status} : null,
      );
      return (data as num?)?.toInt() ?? 0;
    } catch (e) {
      // Fallback: fetch and count
      final orders = await getOrders(status: status, limit: 9999);
      return orders.length;
    }
  }
}
