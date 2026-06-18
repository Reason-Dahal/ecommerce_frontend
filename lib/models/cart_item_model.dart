import 'package:ecommerce_frontend/models/product_model.dart';

class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final String url;
  final String category;
  final int quantity;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.url,
    required this.category,
    required this.quantity,
  });

  double get total => price * quantity;

  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      productId: product.id,
      name: product.name,
      price: product.price.toDouble(),
      url: product.url,
      category: product.category,
      quantity: quantity,
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      name: name,
      price: price,
      url: url,
      category: category,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'url': url,
    'category': category,
    'quantity': quantity,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      url: json['url'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }
}
