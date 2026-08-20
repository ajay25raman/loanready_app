import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  static const String baseUrl = "https://loan.edugaondev.com/api/v1";

  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/users/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw Exception(body["message"] ?? "Failed to fetch user");
    }
  }
}