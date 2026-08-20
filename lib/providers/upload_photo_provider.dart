import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadPhotoProvider extends ChangeNotifier {
  File? _image;
  File? get image => _image;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ImagePicker _picker = ImagePicker();

  static const String _baseUrl =
      "https://loan-approval-api-faur.onrender.com/api/v1";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // Pick Image from Source (Camera / Gallery)
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Image picking error: $e");
    }
  }

  // Clear or Reset Image
  void clearImage() {
    _image = null;
    notifyListeners();
  }

  // 🚀 API Call: Upload Profile Picture via Multipart Request
  Future<Map<String, dynamic>> uploadProfilePic() async {
    if (_image == null) {
      return {'success': false, 'message': 'No image selected'};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'Authentication token not found'};
      }

      // Create Multipart Request
      final uri = Uri.parse("$_baseUrl/users/profile-pic");
      final request = http.MultipartRequest('POST', uri);

      // Add Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add File Payload
      request.files.add(
        await http.MultipartFile.fromPath('profilePic', _image!.path),
      );

      // Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Photo Uploaded Successfully!'};
      } else {
        return {'success': false, 'message': 'Upload Failed: ${response.body}'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}