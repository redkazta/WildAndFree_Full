class Profile {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final bool isArtist;
  final bool isVerified;
  final int tokens;
  final int totalSpent;
  final int totalOrders;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  Profile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.role = 'user',
    this.isArtist = false,
    this.isVerified = false,
    this.tokens = 0,
    this.totalSpent = 0,
    this.totalOrders = 0,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String? ?? json['username'] as String? ?? '',
      displayName: (json['display_name'] ?? json['nombre'] ?? json['username']) as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      isArtist: json['is_artist'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      tokens: json['tokens'] as int? ?? 0,
      totalSpent: json['total_spent'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'role': role,
      'is_artist': isArtist,
      'is_verified': isVerified,
      'tokens': tokens,
      'total_spent': totalSpent,
      'total_orders': totalOrders,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  Profile copyWith({
    String? displayName,
    String? avatarUrl,
    String? role,
    bool? isArtist,
    bool? isVerified,
    int? tokens,
  }) {
    return Profile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isArtist: isArtist ?? this.isArtist,
      isVerified: isVerified ?? this.isVerified,
      tokens: tokens ?? this.tokens,
      totalSpent: totalSpent,
      totalOrders: totalOrders,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags,
    );
  }

  String get initials {
    final name = displayName ?? email ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split('@').first.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}
