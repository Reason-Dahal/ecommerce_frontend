import 'dart:convert';

import 'package:ecommerce_frontend/core/api_client.dart';
import 'package:ecommerce_frontend/core/constants.dart';
import 'package:ecommerce_frontend/models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> signup(String name, String email, String password) async {
    final response = await _apiClient.post(
      "${ApiConstants.authUser}/registerUser",
      {"email": email, "username": name, "password": password},
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? "signup failed");
    }
  }

  Future<UserModel> login(String email, String password) async {
    final response = await _apiClient.post(
      "${ApiConstants.authUser}/loginUser",
      {"email": email, "password": password},
    );
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? "login failed");
    }
  }
}
