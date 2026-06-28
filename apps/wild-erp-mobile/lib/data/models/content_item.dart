class ContentItem {
  final String id;
  final String userId;
  final String? userName;
  final String title;
  final String? description;
  final String type; // track, video, image, text
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String status; // pending, approved, rejected
  final String? rejectionReason;
  final int likes;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reviewedAt;

  ContentItem({
    required this.id,
    required this.userId,
    this.userName,
    required this.title,
    this.description,
    this.type = 'track',
    this.mediaUrl,
    this.thumbnailUrl,
    this.status = 'pending',
    this.rejectionReason,
    this.likes = 0,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'track',
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'title': title,
      'description': description,
      'type': type,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'status': status,
      'rejection_reason': rejectionReason,
      'likes': likes,
      'views': views,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
