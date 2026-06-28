class TagCategory {
  final String id;
  final String name;
  final String? description;
  final int tagCount;
  final DateTime createdAt;

  TagCategory({
    required this.id,
    required this.name,
    this.description,
    this.tagCount = 0,
    required this.createdAt,
  });

  factory TagCategory.fromJson(Map<String, dynamic> json) {
    return TagCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      tagCount: json['tag_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Tag {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String name;
  final String? color;
  final int usageCount;
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.name,
    this.color,
    this.usageCount = 0,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String?,
      name: json['name'] as String? ?? '',
      color: json['color'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
