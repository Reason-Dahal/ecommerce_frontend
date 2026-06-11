class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int countInStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.countInStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      countInStock: json['countInStock'],
    );
  }
}
