class WardrobeImageModel {
  final String imageUrl;
  final String userId;
  final DateTime uploadedAt;
  final List<String> tags; // Optional: future use for metadata like color/style/category
  final String? occasion;  // Optional: for future occasion-based filtering

  WardrobeImageModel({
    required this.imageUrl,
    required this.userId,
    required this.uploadedAt,
    this.tags = const [],
    this.occasion,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'userId': userId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'tags': tags,
      'occasion': occasion,
    };
  }

  factory WardrobeImageModel.fromMap(Map<String, dynamic> map) {
    return WardrobeImageModel(
      imageUrl: map['imageUrl'],
      userId: map['userId'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
      tags: List<String>.from(map['tags'] ?? []),
      occasion: map['occasion'],
    );
  }
}
