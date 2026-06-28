class Variant {
  final String id;
  final String productId;
  final String name;
  final String? sku;
  final int priceTokens;
  final int priceAmount;
  final int stock;
  final Map<String, dynamic>? attributes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Variant({
    required this.id,
    required this.productId,
    required this.name,
    this.sku,
    this.priceTokens = 0,
    this.priceAmount = 0,
    this.stock = 0,
    this.attributes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String,
      sku: json['sku'] as String?,
      priceTokens: json['price_tokens'] as int? ?? 0,
      priceAmount: json['price_amount'] as int? ?? 0,
      stock: json['stock'] as int? ?? 0,
      attributes: json['attributes'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'sku': sku,
      'price_tokens': priceTokens,
      'price_amount': priceAmount,
      'stock': stock,
      'attributes': attributes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get inStock => stock > 0;

  String get displayName => sku != null ? '$name ($sku)' : name;
}
