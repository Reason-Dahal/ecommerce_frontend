import 'dart:convert';

import 'package:ecommerce_frontend/core/api_client.dart';
import 'package:ecommerce_frontend/core/constants.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
// import 'package:http/http.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();
  Future<List<ProductModel>> getAllProduct() async {
    final response = await _apiClient.get(
      '${ApiConstants.productUser}/getAllProduct',
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List productsJson = decoded['product'];

      return productsJson.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception("failed to load product");
    }
  }

  Future<ProductModel> getProductById(String productId) async {
    final response = await _apiClient.get(
      '${ApiConstants.productUser}/getProductById/$productId',
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final productJson = decoded['product'];

      return ProductModel.fromJson(productJson);
    } else {
      throw Exception("Failed to load product");
    }
  }
}
