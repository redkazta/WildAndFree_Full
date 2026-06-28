import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/variant.dart';
import '../cache/cache_service.dart';
import 'supabase_service.dart';

class InventoryService {
  static SupabaseClient get _client => SupabaseService.client;

  static Future<List<Product>> getProducts({
    String? search,
    String? category,
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (isActive != null) filters['is_active'] = isActive;
      if (category != null) filters['category'] = category;

      final data = await SupabaseService.fetchCached(
        table: 'products',
        cacheKey: 'products_${category ?? "all"}_${isActive ?? "all"}_$search',
        select: '*',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );

      List<Product> products =
          data.map((json) => Product.fromJson(json)).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        products = products
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                (p.description?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      return products;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Product?> getProductById(String id) async {
    try {
      final data = await SupabaseService.fetchById(
        table: 'products',
        id: id,
      );
      if (data == null) return null;

      // Fetch variants
      final variantsData = await SupabaseService.fetchCached(
        table: 'variants',
        cacheKey: 'variants_$id',
        select: '*',
        filters: {'product_id': id},
        orderBy: 'created_at',
      );

      data['variants'] = variantsData;
      return Product.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'products',
        data: data,
      );
      return Product.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Product> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'products',
        id: id,
        data: data,
      );
      return Product.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteProduct(String id) async {
    try {
      await SupabaseService.delete(table: 'products', id: id);
    } catch (e) {
      rethrow;
    }
  }

  // Variants
  static Future<List<Variant>> getVariants(String productId) async {
    try {
      final data = await SupabaseService.fetchCached(
        table: 'variants',
        cacheKey: 'variants_$productId',
        select: '*',
        filters: {'product_id': productId},
        orderBy: 'created_at',
      );
      return data.map((json) => Variant.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Variant> createVariant(Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.insert(
        table: 'variants',
        data: data,
      );
      CacheService.invalidatePattern('variants');
      return Variant.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Variant> updateVariant(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'variants',
        id: id,
        data: data,
      );
      CacheService.invalidatePattern('variants');
      return Variant.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteVariant(String id) async {
    try {
      await SupabaseService.delete(table: 'variants', id: id);
      CacheService.invalidatePattern('variants');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateStock(
      String variantId, int newStock) async {
    try {
      await SupabaseService.update(
        table: 'variants',
        id: variantId,
        data: {'stock': newStock},
      );
      CacheService.invalidatePattern('variants');
    } catch (e) {
      rethrow;
    }
  }
}
