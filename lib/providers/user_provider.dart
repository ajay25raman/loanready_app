import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loanready_app/Model/user_model.dart';
import 'package:loanready_app/Model/user_profile_model.dart';
import 'package:loanready_app/services/document_service.dart';
import 'package:loanready_app/services/storage_service.dart';
import 'package:loanready_app/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final StorageService _storage = StorageService();
  final DocumentService _documentService = DocumentService();

  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _uploadedPhotoUrl;

  UserProfileModel? _userProfile;
  UserModel? _user;

  bool _isLoading = false;
  bool _isFetchingData = false;
  bool _isGuest = false;

  String? _errorMessage;

  String? _panDocUrl;
  String? _aadhaarDocUrl;
  String? _shopLicenseUrl;
  String? _gstCertificateUrl;
  String? _businessProofUrl;

  bool isPanUploaded = false;
  bool isAadhaarUploaded = false;
  bool isShopLicenseUploaded = false;
  bool isGstUploaded = false;
  bool isBusinessProofUploaded = false;

  // ============================================================
  // GETTERS
  // ============================================================



  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();


  // ============================================================
  // GETTERS & DOCUMENT STATUS (FIXED)
  // ============================================================

  bool get isUploadingImage => _isUploadingImage;
  File? get selectedImage => _selectedImage;
  String? get uploadedPhotoUrl => _uploadedPhotoUrl ?? _userProfile?.photoUrl;
  UserProfileModel? get userProfile => _userProfile;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isFetchingData => _isFetchingData;
  bool get isGuest => _isGuest;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDocuments() async {
    try {
      final result = await _documentService
          .fetchDocuments()
          .timeout(const Duration(seconds: 12));

      // 🔍 STEP 1: Full API Response ko console me check karein
      debugPrint('=== RAW API RESPONSE ===');
      debugPrint('$result');

      if (result['success'] == true || result['status'] == true) {
        // Safe mapping - checks multiple nested levels if present
        final documents = result['documents'] ?? result['data'] ?? result;

        if (documents is Map) {
          // Check all possible key name variants
          _panDocUrl = _extractDocValue(documents, ['panDocUrl', 'pan_doc_url', 'pan', 'pan_url', 'pan_status', 'panStatus']);
          _aadhaarDocUrl = _extractDocValue(documents, ['aadhaarDocUrl', 'aadhaar_doc_url', 'aadhaar', 'aadhaar_url', 'aadhaar_status', 'aadhaarStatus']);
          _shopLicenseUrl = _extractDocValue(documents, ['shopLicenseUrl', 'shop_license_url', 'shop_license', 'shopLicense', 'shop_license_status']);
          _gstCertificateUrl = _extractDocValue(documents, ['gstCertificateUrl', 'gst_certificate_url', 'gst', 'gst_url', 'gst_status']);
          _businessProofUrl = _extractDocValue(documents, ['businessProofUrl', 'business_proof_url', 'business_proof', 'businessProof', 'business_proof_status']);

          // Debug values
          debugPrint('=== PARSED VALUES ===');
          debugPrint('AADHAAR: $_aadhaarDocUrl | Uploaded: $isAadhaarUploaded');
          debugPrint('PAN: $_panDocUrl | Uploaded: $isPanUploaded');
        }
      }
    } on TimeoutException {
      debugPrint('FETCH DOCUMENTS TIMEOUT');
    } catch (e, stack) {
      debugPrint('FETCH DOCUMENTS ERROR => $e');
      debugPrint('STACKTRACE => $stack');
    } finally {
      notifyListeners();
    }
  }

  // Helper function to safely extract keys and handle booleans/strings/urls
  String? _extractDocValue(Map map, List<String> possibleKeys) {
    for (var key in possibleKeys) {
      if (map.containsKey(key) && map[key] != null) {
        final val = map[key].toString().trim();
        if (val.isNotEmpty && val.toLowerCase() != 'null') {
          return val;
        }
      }
    }
    return null;
  }

  // Helper check for boolean / status string / URL
  bool _hasDocumentUrl(String? value) {
    if (value == null) return false;
    final val = value.trim().toLowerCase();

    // Checks if value is boolean 'true', status 'uploaded'/'approved'/'1', or actual URL link
    if (val == 'true' || val == '1' || val == 'uploaded' || val == 'approved' || val == 'success') {
      return true;
    }

    // Normal URL validation check
    return val.isNotEmpty && val != 'null' && val != 'false' && val != '0';
  }
  // ============================================================
  // STATE SETTERS
  // ============================================================

  void setUserProfile(UserProfileModel? profile) {
    _userProfile = profile;
    _populateControllers(profile);
    _syncUserModelFromProfile();
    notifyListeners();
  }

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ============================================================
  // SYNC USER MODEL
  // ============================================================

  void _syncUserModelFromProfile() {
    if (_user == null || _userProfile == null) return;

    final profile = _userProfile!;

    _user = UserModel(
      id: _user!.id,
      fullName: profile.fullName ?? _user!.fullName,
      email: profile.email ?? _user!.email,
      mobile: profile.mobile ?? _user!.mobile,
      photoUrl: profile.photoUrl ?? _user!.photoUrl,
    );
  }

  // ============================================================
  // SELECT IMAGE
  // ============================================================

  void setSelectedImage(File? file) {
    _selectedImage = file;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // ============================================================
  // UPLOAD PROFILE PICTURE
  // ============================================================

  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    if (_isGuest) {
      return {
        'success': false,
        'message': 'Please log in to upload a profile picture.',
      };
    }

    _isUploadingImage = true;
    _selectedImage = imageFile;
    notifyListeners();

    try {
      final result = await _userService.uploadProfilePic(imageFile);

      if (result['success'] == true) {
        _uploadedPhotoUrl = result['profilePic']?.toString();
        await fetchUserData(forceRefresh: true);
      } else {
        _selectedImage = null;
      }

      return result;
    } catch (e) {
      _selectedImage = null;
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  // ============================================================
  // POPULATE FORM CONTROLLERS
  // ============================================================

  void _populateControllers(UserProfileModel? profile) {
    if (profile == null) return;

    nameController.text = profile.fullName ?? '';
    emailController.text = profile.email ?? '';
    addressController.text = profile.address ?? '';

    final rawMobile = profile.mobile ?? '';
    phoneController.text =
        rawMobile.replaceAll('+91', '').replaceAll(' ', '').trim();

    if (profile.dob != null && profile.dob!.trim().isNotEmpty) {
      final rawDob = profile.dob!.trim();

      try {
        final date = DateTime.parse(rawDob);
        dobController.text = DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {
        try {
          final date = DateFormat('dd/MM/yyyy').parseStrict(rawDob);
          dobController.text = DateFormat('dd/MM/yyyy').format(date);
        } catch (_) {
          dobController.text = rawDob;
        }
      }
    } else {
      dobController.clear();
    }
  }

  // ============================================================
  // FETCH CURRENT USER  (FIXED - no unnecessary shimmer)
  // ============================================================

  Future<void> fetchUserData({bool forceRefresh = false}) async {
    // Agar already data hai aur force nahi hai to loading flag mat lagao
    // isse full-screen shimmer nahi dikhega
    final bool showFullLoader = _userProfile == null;

    if (showFullLoader) {
      _isFetchingData = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _isGuest = await _storage.getGuestStatus();

      // ============================================================
      // GUEST USER
      // ============================================================
      if (_isGuest) {
        final prefs = await SharedPreferences.getInstance();

        final guestName = prefs.getString('guest_name') ?? 'Guest User';
        final guestPhone = prefs.getString('guest_phone') ?? '';
        final guestEmail = prefs.getString('guest_email') ?? '';
        final guestDob = prefs.getString('guest_dob') ?? '';
        final guestAddress = prefs.getString('guest_address') ?? '';

        _userProfile = UserProfileModel(
          fullName: guestName,
          mobile: guestPhone,
          email: guestEmail,
          dob: guestDob,
          address: guestAddress,
          memberSince: '',
        );

        _user = UserModel(
          id: _user?.id ?? 0,
          fullName: guestName,
          email: guestEmail,
          mobile: guestPhone,
          photoUrl: _user?.photoUrl,
        );

        _populateControllers(_userProfile);
      }

      // ============================================================
      // REAL USER  (with timeout + 1 retry)
      // ============================================================
      else {
        UserProfileModel? profile;

        for (int attempt = 1; attempt <= 2; attempt++) {
          try {
            profile = await _userService
                .fetchProfile()
                .timeout(const Duration(seconds: 12));
            break; // success
          } on TimeoutException {
            debugPrint('FETCH PROFILE TIMEOUT (attempt $attempt)');
            if (attempt == 2) rethrow;
            await Future.delayed(const Duration(milliseconds: 700));
          } catch (e) {
            debugPrint('FETCH PROFILE ERROR (attempt $attempt) => $e');
            if (attempt == 2) rethrow;
            await Future.delayed(const Duration(milliseconds: 700));
          }
        }

        if (profile != null) {
          _userProfile = profile;
          _uploadedPhotoUrl = profile.photoUrl;
          _populateControllers(profile);

          if (_user != null) {
            _user = UserModel(
              id: _user!.id,
              fullName: profile.fullName ?? _user!.fullName,
              email: profile.email ?? _user!.email,
              mobile: profile.mobile ?? _user!.mobile,
              photoUrl: profile.photoUrl ?? _user!.photoUrl,
            );
          }
        }
      }

      _errorMessage = null;
    } catch (e) {
      // Sirf tab error dikhao jab pehle se data hi nahi hai
      if (_userProfile == null) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      debugPrint('FETCH USER DATA ERROR => $e');
    } finally {
      _isFetchingData = false;
      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCurrentUser() async {
    await fetchUserData(forceRefresh: true);
  }

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    await fetchUserData(forceRefresh: forceRefresh);
  }

  // ============================================================
  // FETCH DOCUMENTS
  // ============================================================


  // ============================================================
  // SAVE / UPDATE PROFILE
  // ============================================================

  Future<Map<String, dynamic>> saveUserDetails() async {
    if (_isLoading) {
      return {
        'success': false,
        'message': 'Please wait...',
      };
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // GUEST
      if (_isGuest) {
        final profile = UserProfileModel(
          fullName: nameController.text.trim(),
          mobile: phoneController.text.trim(),
          email: emailController.text.trim(),
          dob: dobController.text.trim(),
          address: addressController.text.trim(),
        );

        _userProfile = profile;

        _user = UserModel(
          id: _user?.id ?? 0,
          fullName: profile.fullName ?? 'Guest User',
          email: profile.email ?? '',
          mobile: profile.mobile ?? '',
          photoUrl: profile.photoUrl,
        );

        _populateControllers(profile);
        notifyListeners();

        return {
          'success': true,
          'message': 'Personal details added successfully.',
        };
      }

      // REAL USER
      final rawDob = dobController.text.trim();
      String apiDobFormat = '';

      if (rawDob.isNotEmpty) {
        DateTime? selectedDate;

        try {
          selectedDate = DateFormat('yyyy-MM-dd').parseStrict(rawDob);
        } catch (_) {}

        if (selectedDate == null) {
          try {
            selectedDate = DateFormat('dd/MM/yyyy').parseStrict(rawDob);
          } catch (_) {}
        }

        if (selectedDate == null) {
          try {
            selectedDate = DateTime.parse(rawDob);
          } catch (_) {}
        }

        if (selectedDate == null) {
          _errorMessage = 'Invalid date format. Please select a valid date.';
          return {
            'success': false,
            'message': _errorMessage,
          };
        }

        apiDobFormat = DateFormat('yyyy-MM-dd').format(selectedDate);
      }

      final profile = UserProfileModel(
        fullName: nameController.text.trim(),
        dob: apiDobFormat,
        email: emailController.text.trim(),
        address: addressController.text.trim(),
        mobile: phoneController.text.trim(),
      );

      final result = await _userService.updateUserProfile(profile);

      if (result['success'] == true) {
        _userProfile = profile;
        _populateControllers(profile);

        if (_user != null) {
          _user = UserModel(
            id: _user!.id,
            fullName: profile.fullName ?? _user!.fullName,
            email: profile.email ?? _user!.email,
            mobile: profile.mobile ?? _user!.mobile,
            photoUrl: profile.photoUrl ?? _user!.photoUrl,
          );
        }

        notifyListeners();

        return {
          ...result,
          'success': true,
          'message': result['message']?.toString() ??
              'Personal details added successfully.',
        };
      }

      _errorMessage =
          result['message']?.toString() ?? 'Failed to update personal details.';

      return {
        'success': false,
        'message': _errorMessage,
      };
    } catch (e) {
      debugPrint('SAVE PERSONAL DETAILS ERROR => $e');
      _errorMessage = 'Unable to save personal details. Please try again.';
      return {
        'success': false,
        'message': _errorMessage,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearControllers() {
    nameController.clear();
    dobController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();

    _errorMessage = null;
    _userProfile = null;
    _user = null;
    _selectedImage = null;
    _uploadedPhotoUrl = null;
    _isGuest = false;

    _panDocUrl = null;
    _aadhaarDocUrl = null;
    _shopLicenseUrl = null;
    _gstCertificateUrl = null;
    _businessProofUrl = null;

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }
}