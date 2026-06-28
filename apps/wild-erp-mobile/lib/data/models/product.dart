import 'variant.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final int basePriceTokens;
  final int basePriceAmount;
  final bool isActive;
  final List<Variant> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category = 'general',
    this.basePriceTokens = 0,
    this.basePriceAmount = 0,
    this.isActive = true,
    this.variants = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String? ?? 'general',
      basePriceTokens: json['base_price_tokens'] as int? ?? 0,
      basePriceAmount: json['base_price_amount'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => Variant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'base_price_tokens': basePriceTokens,
      'base_price_amount': basePriceAmount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get totalStock =>
      variants.fold(0, (sum, v) => sum + v.stock);

  bool get inStock => variants.any((v) => v.stock > 0);
}
