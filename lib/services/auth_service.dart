import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:loanready_app/Model/auth_model.dart';

class AuthService {
  final String baseUrl = "https://loan.edugaondev.com/api/v1";

  Future<AuthModel?> sendOtp(
      AuthModel model,
      ) async {
    try {
      final url =
      Uri.parse("$baseUrl/otp/send");

      final response = await http
          .post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },

        body: jsonEncode({
          "countryCode":
          model.countryCode ?? "+91",
          "mobile": model.mobile,
          "templateId": "register",
        }),
      )
          .timeout(
        const Duration(seconds: 15),
      );

      if (response.body.isEmpty) {

        throw Exception(
          "Empty server response.",
        );
      }

      final data =
      jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid server response.",
        );
      }

      return AuthModel.fromJson(data);
    } on TimeoutException {
      throw Exception(
        "Request timed out. Please try again.",
      );
    } on FormatException {
      throw Exception(
        "Invalid server response.",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
          "Exception: ",
          "",
        ),
      );
    }
  }


  Future<AuthModel?> verifyOtp(
      AuthModel model,
      ) async {
    try {
      final url =
      Uri.parse("$baseUrl/otp/verify");

      final response = await http
          .post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "otp": model.otp,
          "verificationId":
          model.verificationId,
        }),
      )
          .timeout(
        const Duration(seconds: 15),
      );

      if (response.body.isEmpty) {
        throw Exception(
          "Empty server response.",
        );
      }

      final data =
      jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid server response.",
        );
      }

      return AuthModel.fromJson(data);
    } on TimeoutException {
      throw Exception(
        "OTP verification timed out. Please try again.",
      );
    } on FormatException {
      throw Exception(
        "Invalid server response.",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst(
          "Exception: ",
          "",
        ),
      );
    }
  }

  Future<bool> checkProfileCompleted(String token) async {
    // Try twice: first attempt + one retry on timeout / network error
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final url = Uri.parse("$baseUrl/users/me");

        final response = await http
            .get(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        )
            .timeout(const Duration(seconds: 12));

        debugPrint(
          "PROFILE CHECK (attempt $attempt) status => ${response.statusCode}",
        );
        debugPrint(
          "PROFILE CHECK (attempt $attempt) body   => ${response.body}",
        );

        if (response.statusCode != 200) {
          if (attempt == 2) return false;
          await Future.delayed(const Duration(milliseconds: 600));
          continue;
        }

        if (response.body.isEmpty) {
          if (attempt == 2) return false;
          await Future.delayed(const Duration(milliseconds: 600));
          continue;
        }

        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic> || data["success"] != true) {
          if (attempt == 2) return false;
          await Future.delayed(const Duration(milliseconds: 600));
          continue;
        }

        final user = data["user"];
        if (user is! Map) {
          if (attempt == 2) return false;
          await Future.delayed(const Duration(milliseconds: 600));
          continue;
        }

        final fullName = user["fullName"]?.toString().trim() ?? "";
        final dob = user["dob"]?.toString().trim() ?? "";
        final mobile = user["mobile"]?.toString().trim() ?? "";
        final email = user["email"]?.toString().trim() ?? "";
        final address = user["address"]?.toString().trim() ?? "";

        final completed = fullName.isNotEmpty &&
            dob.isNotEmpty &&
            mobile.isNotEmpty &&
            email.isNotEmpty &&
            address.isNotEmpty;

        debugPrint(
          "PROFILE CHECK => "
              "fullName=$fullName | dob=$dob | mobile=$mobile | "
              "email=$email | address=$address | completed=$completed",
        );

        return completed;
      } on TimeoutException {
        debugPrint("PROFILE CHECK => TIMEOUT (attempt $attempt)");
        if (attempt == 2) return false;
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (e) {
        debugPrint("PROFILE CHECK ERROR (attempt $attempt) => $e");
        if (attempt == 2) return false;
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    return false;
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