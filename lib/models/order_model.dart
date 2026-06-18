import 'order_item_model.dart';
import 'shipping_address_model.dart';

class OrderModel {
  final String id;
  final String status;
  final double totalPrice;
  final String userId;
  final String? userEmail;
  final ShippingAddressModel shippingAddress;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.userId,
    this.userEmail,
    required this.shippingAddress,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String extractedUserId = '';
    String? extractedEmail;

    if (json['user'] is String) {
      extractedUserId = json['user'];
    } else if (json['user'] is Map<String, dynamic>) {
      extractedUserId = json['user']['_id'] ?? '';
      extractedEmail = json['user']['email'];
    }

    return OrderModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      userId: extractedUserId,
      userEmail: extractedEmail,
      shippingAddress: ShippingAddressModel.fromJson(json['shippingAddress']),
      orderItems: (json['orderItem'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
    );
  }
}
