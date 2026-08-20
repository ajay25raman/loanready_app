import 'dart:convert';
import 'dart:io';

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

    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      Uri.parse(getUserEndpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    Map<String, dynamic> body = {};

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    } catch (_) {
      throw Exception("Invalid server response");
    }

    // ----------------------------------------------------------
    // Success
    // ----------------------------------------------------------

    if (response.statusCode == 200 && body["success"] == true) {
      return UserProfileModel.fromJson(
        body["user"] ?? body,
      );
    }

    // ----------------------------------------------------------
    // Unauthorized
    // ----------------------------------------------------------

    if (response.statusCode == 401) {
      await _storageService.clearToken();

      throw Exception(
        "Session expired. Please login again.",
      );
    }

    throw Exception(
      body["message"] ?? "Failed to load profile",
    );
  }

  // ============================================================
  // ✏️ Update Profile
  // ============================================================

  Future<Map<String, dynamic>> updateUserProfile(
      UserProfileModel profile,
      ) async {
    final token = await _storageService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Authentication token not found!',
      };
    }

    try {
      final response = await http.put(
        Uri.parse(getUserEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(profile.toJson()),
      );

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

      final bool isSuccess =
          (response.statusCode == 200 ||
              response.statusCode == 201) &&
              responseData['success'] == true;

      return {
        'success': isSuccess,
        'message': responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            (isSuccess
                ? 'Profile updated successfully.'
                : 'Failed to update profile'),
        'data': responseData['data'],
        'user': responseData['user'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
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