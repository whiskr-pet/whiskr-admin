class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? shopId;
  final String? shopName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  User({required this.id, required this.email, required this.name, required this.role, this.shopId, this.shopName, required this.createdAt, this.lastLoginAt, required this.isActive});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      shopId: json['shopId'] as String?,
      shopName: json['shopName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'shopId': shopId,
      'shopName': shopName,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  User copyWith({String? id, String? email, String? name, String? role, String? shopId, String? shopName, DateTime? createdAt, DateTime? lastLoginAt, bool? isActive}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
