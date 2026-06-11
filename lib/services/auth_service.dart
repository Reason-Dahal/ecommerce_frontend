import 'dart:convert';

import 'package:ecommerce_flutter/core/api_client.dart';
import 'package:ecommerce_flutter/core/constants.dart';
import 'package:ecommerce_flutter/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> signup(String name, String email, String password) async {
    final response = await _apiClient.post(
      '${ApiConstants.authUser}/registerUser',
      {'email': email, 'username': name, 'password': password},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return UserModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signup Failed');
    }
  }

  Future<UserModel> login(String email, String password) async {
    final response = await _apiClient.post(
      '${ApiConstants.authUser}/loginUser',
      {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      String? tokenCheck = prefs.getString('token');
      print('token $tokenCheck');

      return UserModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signup Failed');
    }
  }
}
