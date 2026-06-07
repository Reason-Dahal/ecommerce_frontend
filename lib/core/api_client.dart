import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String url) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }
}
