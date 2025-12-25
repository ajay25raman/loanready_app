import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:3400/api/v1";

  // 🔹 Send OTP
  static Future<Map<String, dynamic>?> sendOtp(String mobile) async {
    final url = Uri.parse("$baseUrl/otp/send");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "countryCode": "+91",
        "mobile": mobile,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error: ${response.body}");
      return null;
    }
  }

  // 🔹 Verify OTP
  static Future<Map<String, dynamic>?> verifyOtp(
      String mobile, String otp, String verificationId) async {
    final url = Uri.parse("$baseUrl/otp/verify");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "verificationId": verificationId,
      },
      body: jsonEncode({
        "countryCode": "+91",
        "mobile": mobile,
        "otp": otp,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Invalid OTP: ${response.body}");
      return null;
    }
  }
}
