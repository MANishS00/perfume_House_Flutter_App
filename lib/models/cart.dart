class CartItem {
  final String id; // item id in cart document
  final String productId;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'] as String,
      productId: (json['product'] is Map) ? (json['product']['_id'] as String) : (json['product']?.toString() ?? ''),
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      quantity: (json['quantity'] ?? 1) as int,
    );
  }
}

class Cart {
  final String cartId;
  final List<CartItem> items;

  Cart({required this.cartId, required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((i) => CartItem.fromJson(i as Map<String, dynamic>)).toList();
    return Cart(cartId: json['cartId'] ?? '', items: items);
  }
}
