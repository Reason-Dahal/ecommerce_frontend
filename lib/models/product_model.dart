class ProductModel {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String category;
  final String url;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.url,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'url': url,
    };
  }
}
