import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loanready_app/Model/user_profile_model.dart';

import 'storage_service.dart';

class UserService {
  static const String baseUrl = "https://loan.edugaondev.com/api/v1";

  static const String getUserEndpoint = '$baseUrl/users/me';

  // IMPORTANT:
  // Backend ke actual endpoint ke according isko change karein.
  static const String uploadProfilePicEndpoint =
      '$baseUrl/users/profile-picture';

  final StorageService _storageService = StorageService();

  // ============================================================
  // 📷 Upload Profile Picture
  // ============================================================

  Future<Map<String, dynamic>> uploadProfilePic(File imageFile) async {
    try {
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication token not found!',
        };
      }

      if (!await imageFile.exists()) {
        return {
          'success': false,
          'message': 'Selected image file does not exist.',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadProfilePicEndpoint),
      );

      // ----------------------------------------------------------
      // Headers
      // ----------------------------------------------------------

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // ----------------------------------------------------------
      // Image
      // ----------------------------------------------------------

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_pic',
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      );

      // ----------------------------------------------------------
      // Send Request
      // ----------------------------------------------------------

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic> responseData = {};

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (_) {
        // Invalid JSON response
      }

      // ----------------------------------------------------------
      // Unauthorized
      // ----------------------------------------------------------

      if (response.statusCode == 401) {
        await _storageService.clearToken();

        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'isUnauthorized': true,
        };
      }

      // ----------------------------------------------------------
      // Success
      // ----------------------------------------------------------

      if ((response.statusCode == 200 ||
          response.statusCode == 201) &&
          responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message']?.toString() ??
              'Profile picture uploaded successfully.',
          'profilePic': responseData['profilePic'] ??
              responseData['profile_pic'] ??
              responseData['photoUrl'] ??
              responseData['photo_url'],
          'data': responseData['data'],
        };
      }

      // ----------------------------------------------------------
      // Error
      // ----------------------------------------------------------

      return {
        'success': false,
        'message': responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Failed to upload profile picture.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // ============================================================
  // 👤 Fetch Current User Profile
  // ============================================================

  Future<UserProfileModel> fetchProfile() async {
    final token = await _storageService.getToken();

    // ==========================================================
    // TOKEN CHECK
    // ==========================================================

    if (token == null || token.isEmpty) {
      throw Exception("SESSION_EXPIRED");
    }

    try {
      // ========================================================
      // API REQUEST
      // ========================================================

      final response = await http
          .get(
        Uri.parse(getUserEndpoint),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      )
          .timeout(
        const Duration(seconds: 12),
      );

      // ========================================================
      // PARSE RESPONSE
      // ========================================================

      Map<String, dynamic> body = {};

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {
        throw Exception("SERVER_ERROR");
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response.statusCode == 200 &&
          body["success"] == true) {
        return UserProfileModel.fromJson(
          body["user"] ?? body,
        );
      }

      // ========================================================
      // UNAUTHORIZED
      // ========================================================

      if (response.statusCode == 401) {
        await _storageService.clearToken();

        throw Exception("SESSION_EXPIRED");
      }

      // ========================================================
      // SERVER/API ERROR
      // ========================================================

      final message =
      body["message"]?.toString();

      if (message != null &&
          message.isNotEmpty) {
        throw Exception(message);
      }

      throw Exception("PROFILE_LOAD_FAILED");
    }

    // ==========================================================
    // NO INTERNET
    // ==========================================================

    on SocketException {
      throw Exception("NO_INTERNET");
    }

    // ==========================================================
    // HTTP CLIENT / CONNECTION ABORTED
    // ==========================================================

    on http.ClientException {
      throw Exception("CONNECTION_ABORTED");
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================

    on TimeoutException {
      throw Exception("REQUEST_TIMEOUT");
    }

    // ==========================================================
    // OTHER ERROR
    // ==========================================================

    catch (e) {
      final error =
      e.toString().toLowerCase();

      debugPrint(
        "FETCH PROFILE ERROR => $e",
      );

      // Network related errors
      if (error.contains("socketexception") ||
          error.contains("failed host lookup") ||
          error.contains(
            "no address associated with hostname",
          ) ||
          error.contains("network is unreachable")) {
        throw Exception("NO_INTERNET");
      }

      // Connection aborted
      if (error.contains("clientexception") ||
          error.contains("connection abort") ||
          error.contains("connection reset") ||
          error.contains("connection closed")) {
        throw Exception("CONNECTION_ABORTED");
      }

      // Timeout
      if (error.contains("timeout") ||
          error.contains("timed out")) {
        throw Exception("REQUEST_TIMEOUT");
      }

      // Already safe error hai
      if (error.contains("session_expired") ||
          error.contains("server_error") ||
          error.contains("profile_load_failed")) {
        rethrow;
      }

      // Never expose raw technical error
      throw Exception("PROFILE_LOAD_FAILED");
    }
  }

  // ============================================================
  // ✏️ Update Profile
  // ============================================================

  Future<Map<String, dynamic>> updateUserProfile(
      UserProfileModel profile,
      ) async {
    try {
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication token not found!',
        };
      }

      final stopwatch = Stopwatch()..start();

      final response = await http
          .put(
        Uri.parse(getUserEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(profile.toJson()),
      )
          .timeout(
        const Duration(seconds: 15),
      );

      stopwatch.stop();

      debugPrint(
        'UPDATE PROFILE API => '
            '${stopwatch.elapsedMilliseconds} ms',
      );

      Map<String, dynamic> responseData = {};

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            responseData = decoded;
          }
        } catch (_) {
          return {
            'success': false,
            'message': 'Invalid server response.',
          };
        }
      }

      // ----------------------------------------------------------
      // UNAUTHORIZED
      // ----------------------------------------------------------

      if (response.statusCode == 401) {
        await _storageService.clearToken();

        return {
          'success': false,
          'message':
          'Session expired. Please login again.',
          'isUnauthorized': true,
        };
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      final isSuccess =
          (response.statusCode == 200 ||
              response.statusCode == 201) &&
              responseData['success'] == true;

      if (isSuccess) {
        return {
          'success': true,
          'message':
          responseData['message']?.toString() ??
              'Personal details added successfully.',
          'data': responseData['data'],
          'user': responseData['user'],
        };
      }

      // ----------------------------------------------------------
      // API ERROR
      // ----------------------------------------------------------

      return {
        'success': false,
        'message':
        responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Failed to update personal details.',
      };
    } on TimeoutException {
      debugPrint(
        'UPDATE PROFILE API TIMEOUT',
      );

      return {
        'success': false,
        'message':
        'Server is taking too long. Please try again.',
      };
    } catch (e) {
      debugPrint(
        'UPDATE PROFILE ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to update personal details. Please try again.',
      };
    }
  }
  // ============================================================
  // 🚪 Logout
  // ============================================================

  Future<void> logout() async {
    await _storageService.clearToken();
  }
}