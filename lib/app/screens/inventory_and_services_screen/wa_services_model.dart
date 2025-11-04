import 'package:w_utils/models/image_model.dart';

class WAServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final ImageModel image;
  final double price;
  final String currency;
  final bool active;

  WAServiceModel({required this.id, required this.name, required this.description, required this.category, required this.image, required this.price, required this.currency, required this.active});

  factory WAServiceModel.fromJson(Map<String, dynamic> json) {
    return WAServiceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] != null ? ImageModel.fromJson(json['image'] as Map<String, dynamic>) : ImageModel(url: '', thumbnail: ''),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BAM',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'category': category, 'image': image.toJson(), 'price': price, 'currency': currency, 'active': active};
  }

  WAServiceModel copyWith({String? id, String? name, String? description, String? category, ImageModel? image, double? price, String? currency, bool? active}) {
    return WAServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      active: active ?? this.active,
    );
  }

  @override
  String toString() {
    return 'WAServiceModel(id: $id, name: $name, description: $description, category: $category, price: $price, currency: $currency, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WAServiceModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.image == image &&
        other.price == price &&
        other.currency == currency &&
        other.active == active;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ description.hashCode ^ category.hashCode ^ image.hashCode ^ price.hashCode ^ currency.hashCode ^ active.hashCode;
  }
}
