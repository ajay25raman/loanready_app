import 'package:flutter/foundation.dart';
import '../Model/user_model.dart';
import '../providers/user_provider.dart';
import '../services/user_api_service.dart';

class UserController {
  final UserApiService _api = UserApiService();

  Future<bool> fetchCurrentUser(UserProvider provider) async {
    provider.setLoading(true);

    try {
      final response = await _api.getCurrentUser();

      debugPrint("API RESPONSE => $response");

      if (response != null &&
          response["success"] == true &&
          response["user"] != null) {

        final user = UserModel.fromJson(response["user"] as Map<String, dynamic>);

        provider.setUser(user);

        debugPrint("USER NAME => ${user.fullName}");
        return true;
      } else {
        debugPrint("User data not found or invalid format");
        provider.setUser(null);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("FETCH USER ERROR => $e");
      debugPrintStack(stackTrace: stackTrace);
      provider.setUser(null);
      return false;
    } finally {
      provider.setLoading(false);
    }
  }
}