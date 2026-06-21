import 'product_model.dart';

class OrderItemModel {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String productRef;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.productRef,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawRef = json['productRef'];
    String refId = '';
    ProductModel? product;

    if (rawRef is String) {
      refId = rawRef;
    } else if (rawRef is Map<String, dynamic>) {
      refId = rawRef['_id']?.toString() ?? '';
      product = ProductModel.fromJson(rawRef);
    }

    return OrderItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      productRef: refId,
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "quantity": quantity,
      "price": price,
      "productRef": productRef,
    };
  }
}
