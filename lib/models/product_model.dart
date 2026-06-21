class ProductModel {
  final String id;
  final String name;
  final num price;
  final int stock;
  final String category;
  final String url;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.url,
  });

  /// Parses the standard API response shape.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      category: json['category']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }

  /// Flat shape used for local caching (wishlist, etc.)
  Map<String, dynamic> toCache() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
    'category': category,
    'url': url,
  };

  /// Reads back the flat shape produced by [toCache].
  factory ProductModel.fromCache(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      category: json['category']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}
