import 'dart:convert';
import 'package:ecommerce_frontend/core/api_client.dart';
import 'package:ecommerce_frontend/core/constants.dart';
import 'package:ecommerce_frontend/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<UserModel> signup(String name, String email, String password) async {
    final response = await _apiClient.post(
      "${ApiConstants.authUser}/registerUser",
      {"email": email, "username": name, "password": password},
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data);
      await _saveUser(user);
      return user;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? "signup failed");
    }
  }

  Future<UserModel> login(String email, String password) async {
    final response = await _apiClient.post(
      "${ApiConstants.authUser}/loginUser",
      {"email": email, "password": password},
    );

    print('LOGIN status: ${response.statusCode}');
    print('LOGIN body: "${response.body}"');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Server returned an empty response on login');
      }

      final data = jsonDecode(response.body);

      final user = UserModel.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['token']);
      await _saveUser(user, prefs: prefs);

      return user;
    } else {
      if (response.body.isEmpty) {
        throw Exception(
          'Login failed with status ${response.statusCode} and no message',
        );
      }
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

  /// Caches the logged-in user as JSON so it survives app restarts.
  Future<void> _saveUser(UserModel user, {SharedPreferences? prefs}) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Returns the cached user, or null if no one is logged in.
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;

    try {
      return UserModel.fromCache(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<UserModel> updateProfile(String username) async {
    final response = await _apiClient.put(
      "${ApiConstants.authUser}/updateProfile",
      {"username": username},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final user = UserModel.fromJson(data);

      // update cached user
      await _saveUser(user);

      return user;
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? "profile update failed",
      );
    }
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _apiClient.put(
      "${ApiConstants.authUser}/updatePassword",
      {"currentPassword": currentPassword, "newPassword": newPassword},
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? "password update failed",
      );
    }
  }
}
