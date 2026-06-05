import 'dart:convert';

import 'package:ecommerce_flutter/core/api_client.dart';
import 'package:ecommerce_flutter/core/constants.dart';
import 'package:ecommerce_flutter/models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> signup(String name, String email, String password) async {
    final response = await _apiClient.post(
      '${ApiConstants.authUser}/registerUser',
      {'email': email, 'username': name, 'password': password},
    );

    print("response ${response.body}");
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("data $data");

      return UserModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signup Failed');
    }
  }
}
