import 'dart:convert';
import 'package:ecommerce_frontend/core/api_client.dart';
import 'package:ecommerce_frontend/core/constants.dart';
import 'package:ecommerce_frontend/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  static const _tokenKey = 'auth_token';

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
    // print("STATUS CODE: ${response.statusCode}");
    // print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print("data $data");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      return UserModel.fromJson(data);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? "login failed");
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Called after login to read back the token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
