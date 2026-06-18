import 'dart:convert';
import 'package:ecommerce_frontend/core/api_client.dart';
import 'package:ecommerce_frontend/core/constants.dart';
import 'package:ecommerce_frontend/models/order_model.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  /// CREATE ORDER
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> orderItems,
    required String city,
    required int postalCode,
    required int phone,
    required double totalPrice,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.order}/createOrder',
      {
        "orderItem": orderItems,
        "shippingAddress": {
          "city": city,
          "postalCode": postalCode,
          "phone": phone,
        },
        "totalPrice": totalPrice,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      return OrderModel.fromJson(decoded['order']);
    }

    throw Exception("Failed to create order");
  }

  /// GET MY ORDERS
  Future<List<OrderModel>> getMyOrders() async {
    final response = await _apiClient.get('${ApiConstants.order}/getMyOrder');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List ordersJson = decoded['orders'];

      return ordersJson.map((e) => OrderModel.fromJson(e)).toList();
    }

    throw Exception("Failed to fetch orders");
  }

  /// GET ALL ORDERS (ADMIN)
  Future<List<OrderModel>> getAllOrders() async {
    final response = await _apiClient.get('${ApiConstants.order}/getAllOrder');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List ordersJson = decoded['orders'];

      return ordersJson.map((e) => OrderModel.fromJson(e)).toList();
    }

    throw Exception("Failed to fetch all orders");
  }

  /// UPDATE ORDER STATUS (ADMIN)
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.order}/updateOrderStatus/$orderId',
      {"status": status},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return OrderModel.fromJson(decoded['updatedOrder']);
    }

    throw Exception("Failed to update order status");
  }

  Future<void> deleteOrder({required String orderId}) async {
    final response = await _apiClient.delete(
      '${ApiConstants.order}/deleteOrder/$orderId',
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception("Failed to delete order");
  }
}
