import 'package:ecommerce_frontend/models/order_item_model.dart';
import 'package:ecommerce_frontend/models/shipping_address_model.dart';

class OrderModel {
  final String id;
  final String status;
  final double totalPrice;
  final String userId;
  final String? userEmail;
  final String? userName;
  final ShippingAddressModel shippingAddress;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.userId,
    this.userEmail,
    this.userName,
    required this.shippingAddress,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String extractedUserId = '';
    String? extractedEmail;
    String? extractedName;

    if (json['user'] is String) {
      extractedUserId = json['user'];
    } else if (json['user'] is Map<String, dynamic>) {
      extractedUserId = json['user']['_id'] ?? '';
      extractedEmail = json['user']['email'];
      extractedName = json['user']['username'];
    }

    return OrderModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      userId: extractedUserId,
      userEmail: extractedEmail,
      userName: extractedName,
      shippingAddress: ShippingAddressModel.fromJson(json['shippingAddress']),
      orderItems: (json['orderItem'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
    );
  }
}
