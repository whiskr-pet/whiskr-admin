class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({required this.name, required this.price, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(name: json['name'] as String, price: (json['price'] as num).toDouble(), quantity: json['quantity'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  double get subtotal => price * quantity;

  @override
  String toString() => 'OrderItem(name: $name, price: $price, quantity: $quantity)';
}
