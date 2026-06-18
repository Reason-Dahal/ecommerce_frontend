import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

  // Future<void> addProduct({
  //   required String name,
  //   required double price,
  //   required String category,
  //   required int stock,
  //   required String url,
  // }) async {
  //   final response = await _apiClient.post(
  //     '${ApiConstants.productUser}/addProduct',
  //     {
  //       "name": name,
  //       "price": price,
  //       "category": category,
  //       "stock": stock,
  //       "url": url,
  //     },
  //   );

  //   if (response.statusCode != 200 && response.statusCode != 201) {
  //     throw Exception("Failed to add product");
  //   }
  // }
  Future<void> addProduct({
    required String name,
    required double price,
    required String category,
    required int stock,
    required File url,
  }) async {
    final streamedResponse = await _apiClient.multipartPost(
      endPoint: "${ApiConstants.productUser}/addproduct",
      fields: {
        "name": name,
        "price": price.toString(),
        "category": category,
        "stock": stock.toString(),
      },
      url: url,
    );

    final response = await http.Response.fromStream(streamedResponse);

    print('ADD PRODUCT status: ${response.statusCode}');
    print('ADD PRODUCT body: "${response.body}"');

    if (response.statusCode != 201) {
      throw Exception("Failed to add product");
    }
  }

  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    double? price,
    String? category,
    int? stock,
    String? url,
  }) async {
    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (price != null) body['price'] = price;
    if (category != null) body['category'] = category;
    if (stock != null) body['stock'] = stock;
    if (url != null) body['url'] = url;

    final response = await _apiClient.put(
      '${ApiConstants.productUser}/updateProduct/$productId',
      body,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return ProductModel.fromJson(decoded['product']);
    } else {
      throw Exception("Failed to update product");
    }
  }

  Future<void> deleteProduct(String productId) async {
    final response = await _apiClient.delete(
      '${ApiConstants.productUser}/deleteProduct/$productId',
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete product");
    }
  }
}
