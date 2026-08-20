import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OneYearReportApiService {
  static const String baseUrl =
      "https://loan.edugaondev.com/api/v1";

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("auth_token");

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }

    return token;
  }

  Future<Map<String, dynamic>> getAllReports() async {
    final token = await _getToken();

    final url = Uri.parse(
      "$baseUrl/trade/one-year/all",
    );

    print("========== FINANCIAL REPORT API ==========");
    print("URL => $url");
    debugPrint("TOKEN EXISTS => ${token.isNotEmpty}");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    debugPrint("STATUS => ${response.statusCode}");
    debugPrint("BODY => ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "API Error ${response.statusCode}: ${response.body}",
      );
    }

    if (response.body.trim().startsWith("<!DOCTYPE") ||
        response.body.trim().startsWith("<html")) {
      throw Exception(
        "Server returned HTML instead of JSON. Check API URL/route.",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid API response format");
    }

    return decoded;
  }

  Future<Map<String, dynamic>> getLatestReport() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/trade/one-year/latest"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(
      body["message"] ?? "Failed to fetch latest report",
    );
  }

  Future<Map<String, dynamic>> getReportById(int id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/trade/one-year/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(
      body["message"] ?? "Failed to fetch report",
    );
  }
}