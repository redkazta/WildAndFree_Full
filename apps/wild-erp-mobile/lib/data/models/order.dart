import 'product.dart';

class Order {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final List<OrderItem> items;
  final int totalTokens;
  final int totalAmount;
  final String status;
  final String? notes;
  final String? shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.items = const [],
    this.totalTokens = 0,
    this.totalAmount = 0,
    this.status = 'pending',
    this.notes,
    this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalTokens: json['total_tokens'] as int? ?? 0,
      totalAmount: json['total_amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'items': items.map((e) => e.toJson()).toList(),
      'total_tokens': totalTokens,
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
      'shipping_address': shippingAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderItem {
  final String id;
  final String productId;
  final String? productName;
  final String? variantId;
  final String? variantName;
  final int quantity;
  final int priceTokens;
  final int priceAmount;

  OrderItem({
    required this.id,
    required this.productId,
    this.productName,
    this.variantId,
    this.variantName,
    this.quantity = 1,
    this.priceTokens = 0,
    this.priceAmount = 0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String?,
      variantId: json['variant_id'] as String?,
      variantName: json['variant_name'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      priceTokens: json['price_tokens'] as int? ?? 0,
      priceAmount: json['price_amount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'variant_id': variantId,
      'variant_name': variantName,
      'quantity': quantity,
      'price_tokens': priceTokens,
      'price_amount': priceAmount,
    };
  }

  int get subtotalTokens => priceTokens * quantity;
  int get subtotalAmount => priceAmount * quantity;
}
