import 'dart:convert';

import 'package:ecommerce_flutter/core/api_client.dart';
import 'package:ecommerce_flutter/core/constants.dart';
import 'package:ecommerce_flutter/models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductModel>> getProducts() async {
    final response = await _apiClient.get(
      '${ApiConstants.product}/getAllProducts',
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    final response = await _apiClient.post(
      '${ApiConstants.baseUrl}/products',
      productData,
    );
    if (response.statusCode == 201) return true;
    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Failed to create product',
    );
  }

  // Admin: Update Product
  Future<bool> updateProduct(
    String id,
    Map<String, dynamic> productData,
  ) async {
    final response = await _apiClient.put(
      '${ApiConstants.baseUrl}/products/$id',
      productData,
    );
    if (response.statusCode == 200) return true;
    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Failed to update product',
    );
  }

  // Admin: Delete Product
  Future<bool> deleteProduct(String id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.baseUrl}/products/$id',
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to delete product');
  }
}
