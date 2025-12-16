class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images[0]['url'] as String
        : '';
    final priceObj = json['price'] ?? {};
    final value = (priceObj['final_price'] ?? priceObj['value'] ?? 0)
        .toDouble();

    return Product(
      id: json['_id'] as String,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: value,
      imageUrl: imageUrl,
      images: images != null
          ? images.map((img) => img['url'] as String).toList()
          : [],
    );
  }
}
