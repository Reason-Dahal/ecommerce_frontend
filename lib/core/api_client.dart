import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<http.Response> get(String url) async {
    final response = await http.get(Uri.parse(url));
    return response;
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }
}
