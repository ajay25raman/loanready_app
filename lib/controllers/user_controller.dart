import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Model/user_model.dart';
import '../providers/user_provider.dart';
import '../services/user_api_service.dart';

class UserController {
  final UserApiService _api = UserApiService();

  Future<bool> fetchCurrentUser(UserProvider provider) async {
    provider.setLoading(true);

    try {
      Map<String, dynamic>? response;

      // 1 retry on timeout
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          response = await _api
              .getCurrentUser()
              .timeout(const Duration(seconds: 12));
          break;
        } on TimeoutException {
          debugPrint('FETCH CURRENT USER TIMEOUT (attempt $attempt)');
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 700));
        } catch (e) {
          debugPrint('FETCH CURRENT USER ERROR (attempt $attempt) => $e');
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 700));
        }
      }

      debugPrint("API RESPONSE => $response");

      if (response != null &&
          response["success"] == true &&
          response["user"] != null) {

        final user = UserModel.fromJson(
          response["user"] as Map<String, dynamic>,
        );

        provider.setUser(user);
        debugPrint("USER NAME => ${user.fullName}");
        return true;
      } else {
        debugPrint("User data not found or invalid format");
        // purana user mat hatao
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("FETCH USER ERROR => $e");
      debugPrintStack(stackTrace: stackTrace);
      // fail hone pe bhi purana user mat hatao
      return false;
    } finally {
      provider.setLoading(false);
    }
  }
}