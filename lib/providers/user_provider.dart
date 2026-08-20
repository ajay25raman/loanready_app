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
  final DocumentService _documentService =
  DocumentService();

  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _uploadedPhotoUrl;

  UserProfileModel? _userProfile;
  UserModel? _user;

  bool _isLoading = false;
  bool _isFetchingData = false;
  bool _isGuest = false;

  String? _errorMessage;
  String? panDocUrl;
  String? aadhaarDocUrl;
  String? shopLicenseUrl;
  String? gstCertificateUrl;
  String? businessProofUrl;
  String? _panDocUrl;
  String? _aadhaarDocUrl;
  String? _shopLicenseUrl;
  String? _gstCertificateUrl;
  String? _businessProofUrl;



  bool get isPanUploaded =>
      _panDocUrl != null &&
          _panDocUrl!.trim().isNotEmpty;

  bool get isAadhaarUploaded =>
      _aadhaarDocUrl != null &&
          _aadhaarDocUrl!.trim().isNotEmpty;

  bool get isShopLicenseUploaded =>
      _shopLicenseUrl != null &&
          _shopLicenseUrl!.trim().isNotEmpty;

  bool get isGstUploaded =>
      _gstCertificateUrl != null &&
          _gstCertificateUrl!.trim().isNotEmpty;

  bool get isBusinessProofUploaded =>
      _businessProofUrl != null &&
          _businessProofUrl!.trim().isNotEmpty;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isUploadingImage => _isUploadingImage;

  File? get selectedImage => _selectedImage;

  String? get uploadedPhotoUrl =>
      _uploadedPhotoUrl ?? _userProfile?.photoUrl;

  UserProfileModel? get userProfile => _userProfile;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isFetchingData => _isFetchingData;

  bool get isGuest => _isGuest;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController dobController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  // ============================================================
  // STATE SETTERS
  // ============================================================

  void setUserProfile(UserProfileModel? profile) {
    _userProfile = profile;

    _populateControllers(profile);

    // IMPORTANT:
    // Profile se UserModel bhi update hoga.
    _syncUserModelFromProfile();

    notifyListeners();
  }

  Future<void> fetchDocuments() async {
    try {
      final result = await _documentService.fetchDocuments();

      debugPrint(
        'FETCH DOCUMENTS RESULT => $result',
      );

      if (result['success'] == true) {
        final documents = result['documents'];

        if (documents is Map) {
          _panDocUrl =
              documents['pan_doc_url']?.toString();

          _aadhaarDocUrl =
              documents['aadhaar_doc_url']?.toString();

          _shopLicenseUrl =
              documents['shop_license_url']?.toString();

          _gstCertificateUrl =
              documents['gst_certificate_url']?.toString();

          _businessProofUrl =
              documents['business_proof_url']?.toString();

          debugPrint(
            'PAN => $_panDocUrl',
          );

          debugPrint(
            'AADHAAR => $_aadhaarDocUrl',
          );
        }
      }
    } catch (e) {
      debugPrint(
        'FETCH DOCUMENTS ERROR => $e',
      );
    }

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
    if (_user == null || _userProfile == null) {
      return;
    }

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

  Future<Map<String, dynamic>> uploadProfilePicture(
      File imageFile,
      ) async {
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
      final result =
      await _userService.uploadProfilePic(imageFile);

      if (result['success'] == true) {
        _uploadedPhotoUrl =
            result['profilePic']?.toString();

        // API se fresh profile fetch.
        await fetchUserData();
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

  void _populateControllers(
      UserProfileModel? profile,
      ) {
    if (profile == null) {
      return;
    }

    nameController.text =
        profile.fullName ?? '';

    emailController.text =
        profile.email ?? '';

    addressController.text =
        profile.address ?? '';

    final rawMobile =
        profile.mobile ?? '';

    phoneController.text = rawMobile
        .replaceAll('+91', '')
        .replaceAll(' ', '')
        .trim();

    if (profile.dob != null &&
        profile.dob!.trim().isNotEmpty) {
      final rawDob = profile.dob!.trim();

      try {
        final date = DateTime.parse(rawDob);

        dobController.text =
            DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {
        try {
          final date =
          DateFormat('dd/MM/yyyy')
              .parseStrict(rawDob);

          dobController.text =
              DateFormat('dd/MM/yyyy').format(date);
        } catch (_) {
          dobController.text = rawDob;
        }
      }
    } else {
      dobController.clear();
    }
  }

  // ============================================================
  // FETCH CURRENT USER
  // ============================================================

// 📥 Fetch User Profile
  Future<void> fetchUserData() async {
    _isFetchingData = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _isGuest = await _storage.getGuestStatus();

      // ============================================================
      // GUEST USER
      // ============================================================

      if (_isGuest) {
        final prefs =
        await SharedPreferences.getInstance();

        final guestName =
            prefs.getString('guest_name') ??
                'Guest User';

        final guestPhone =
            prefs.getString('guest_phone') ??
                '';

        final guestEmail =
            prefs.getString('guest_email') ??
                '';

        final guestDob =
            prefs.getString('guest_dob') ??
                '';

        final guestAddress =
            prefs.getString('guest_address') ??
                '';

        // ----------------------------------------------------------
        // Create Guest Profile
        // ----------------------------------------------------------

        _userProfile = UserProfileModel(
          fullName: guestName,
          mobile: guestPhone,
          email: guestEmail,
          dob: guestDob,
          address: guestAddress,
          memberSince: '',
        );

        // ----------------------------------------------------------
        // Update UserModel also
        // ----------------------------------------------------------

        _user = UserModel(
          id: _user?.id ?? 0,
          fullName: guestName,
          email: guestEmail,
          mobile: guestPhone,
          photoUrl: _user?.photoUrl,
        );

        // ----------------------------------------------------------
        // Populate Controllers
        // ----------------------------------------------------------

        _populateControllers(
          _userProfile,
        );
      }

      // ============================================================
      // REAL USER
      // ============================================================

      else {
        final profile =
        await _userService.fetchProfile();

        _userProfile = profile;

        // Update photo
        _uploadedPhotoUrl =
            profile.photoUrl;

        // Update form controllers
        _populateControllers(
          profile,
        );

        // ----------------------------------------------------------
        // IMPORTANT:
        // HomeScreen provider.user ko bhi update karo
        // ----------------------------------------------------------

        if (_user != null) {
          _user = UserModel(
            id: _user!.id,
            fullName:
            profile.fullName ??
                _user!.fullName,
            email:
            profile.email ??
                _user!.email,
            mobile:
            profile.mobile ??
                _user!.mobile,
            photoUrl:
            profile.photoUrl ??
                _user!.photoUrl,
          );
        }
      }
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint(
        'FETCH USER DATA ERROR => $_errorMessage',
      );
    } finally {
      _isFetchingData = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH CURRENT USER
  // ============================================================

  Future<void> refreshCurrentUser() async {
    await fetchUserData();
  }

  // ============================================================
  // FETCH PROFILE ALIAS
  // ============================================================

  Future<void> fetchProfile() async {
    await fetchUserData();
  }

  // ============================================================
  // SAVE / UPDATE PROFILE
  // ============================================================

  Future<Map<String, dynamic>> saveUserDetails() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _isGuest =
      await _storage.getGuestStatus();

      // ========================================================
      // GUEST USER
      // ========================================================

      if (_isGuest) {
        _userProfile =
            UserProfileModel(
              fullName:
              nameController.text.trim(),
              mobile:
              phoneController.text.trim(),
              email:
              emailController.text.trim(),
              dob:
              dobController.text.trim(),
              address:
              addressController.text.trim(),
            );

        // IMPORTANT:
        // Guest ke UserModel ko bhi update karo.
        _user = UserModel(
          id: _user?.id ?? 0,
          fullName:
          _userProfile?.fullName ?? 'Guest User',
          email:
          _userProfile?.email ?? '',
          mobile:
          _userProfile?.mobile ?? '',
          photoUrl:
          _userProfile?.photoUrl,
        );

        _populateControllers(
          _userProfile,
        );

        notifyListeners();

        return {
          'success': true,
          'message': 'Guest profile updated',
        };
      }

      // ========================================================
      // REAL USER
      // ========================================================

      String apiDobFormat = '';

      final dob =
      dobController.text.trim();

      if (dob.isNotEmpty) {
        DateTime? selectedDate;

        // yyyy-MM-dd
        try {
          selectedDate =
              DateFormat('yyyy-MM-dd')
                  .parseStrict(dob);
        } catch (_) {}

        // dd/MM/yyyy
        if (selectedDate == null) {
          try {
            selectedDate =
                DateFormat('dd/MM/yyyy')
                    .parseStrict(dob);
          } catch (_) {}
        }

        // ISO DateTime
        if (selectedDate == null) {
          try {
            selectedDate =
                DateTime.parse(dob);
          } catch (_) {}
        }

        // Invalid date
        if (selectedDate == null) {
          _errorMessage =
          'Invalid date format. Please select a valid date.';

          return {
            'success': false,
            'message': _errorMessage,
          };
        }

        apiDobFormat =
            DateFormat('yyyy-MM-dd')
                .format(selectedDate);
      }

      // ========================================================
      // CREATE PROFILE MODEL
      // ========================================================

      final profile =
      UserProfileModel(
        fullName:
        nameController.text.trim(),
        dob: apiDobFormat,
        email:
        emailController.text.trim(),
        address:
        addressController.text.trim(),
        mobile:
        phoneController.text.trim(),
      );

      // ========================================================
      // API UPDATE
      // ========================================================

      final result =
      await _userService.updateUserProfile(
        profile,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (result['success'] == true) {
        // Pehle local state immediately update karo
        _userProfile = profile;

        _populateControllers(
          _userProfile,
        );

        // IMPORTANT:
        // HomeScreen ke provider.user ko immediately update karo.
        if (_user != null) {
          _user = UserModel(
            id: _user!.id,
            fullName:
            profile.fullName ??
                _user!.fullName,
            email:
            profile.email ??
                _user!.email,
            mobile:
            profile.mobile ??
                _user!.mobile,
            photoUrl:
            profile.photoUrl ??
                _user!.photoUrl,
          );
        }

        // UI immediately refresh
        notifyListeners();

        // API se fresh data bhi fetch karo.
        // Isse database/API ka actual latest value confirm ho jayega.
        await fetchUserData();
      } else {
        _errorMessage =
            result['message']?.toString() ??
                'Failed to update profile';
      }

      return result;
    } catch (e) {
      _errorMessage =
          e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      debugPrint(
        'SAVE USER DETAILS ERROR => $_errorMessage',
      );

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
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _userService.logout();

    clearControllers();
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