class ServiceOffering {
  final String id;
  final String shopId;
  final String name;
  final String type; // e.g., grooming, walking, training
  final String description;
  final double price;
  final int? durationMinutes; // optional, for time-based services
  final List<String> tags;
  final bool isActive;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceOffering({
    required this.id,
    required this.shopId,
    required this.name,
    required this.type,
    required this.description,
    required this.price,
    this.durationMinutes,
    required this.tags,
    required this.isActive,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceOffering.fromJson(Map<String, dynamic> json) {
    return ServiceOffering(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      tags: List<String>.from((json['tags'] as List?) ?? const []),
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'type': type,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'tags': tags,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ServiceOffering copyWith({
    String? id,
    String? shopId,
    String? name,
    String? type,
    String? description,
    double? price,
    int? durationMinutes,
    List<String>? tags,
    bool? isActive,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceOffering(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
