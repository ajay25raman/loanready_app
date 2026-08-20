import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loanready_app/Model/auth_model.dart';

class AuthService {
  final String baseUrl = "https://loan.edugaondev.com/api/v1";

  Future<AuthModel?> sendOtp(AuthModel model) async {
    final url = Uri.parse("$baseUrl/otp/send");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "countryCode": model.countryCode ?? "+91",
        "mobile": model.mobile,
        "templateId": "register",
      }),
    );

    final data = jsonDecode(response.body);
    return AuthModel.fromJson(data);
  }

  Future<AuthModel?> verifyOtp(AuthModel model) async {
    final url = Uri.parse("$baseUrl/otp/verify");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "otp": model.otp,
        "verificationId": model.verificationId,
      }),
    );

    final data = jsonDecode(response.body);
    return AuthModel.fromJson(data);
  }

  Future<bool> checkProfileCompleted(String token) async {
    try {
      final url = Uri.parse("$baseUrl/users/me");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data["user"];
        if (user != null) {
          return (user["fullName"] ?? "").toString().trim().isNotEmpty &&
              (user["email"] ?? "").toString().trim().isNotEmpty;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<AuthModel?> continueAsGuest() async {
    final url = Uri.parse("https://loan-approval-api-faur.onrender.com/api/v1/users/guest");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    return AuthModel.fromJson(data);
  }

}