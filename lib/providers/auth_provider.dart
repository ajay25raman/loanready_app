import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/Model/auth_model.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool _isLoading = false;
  bool _isSendingOtp = false;
  bool _isGuestLoading = false;
  bool _isResendingOtp = false;

  bool get isLoading => _isLoading;
  bool get isSendingOtp => _isSendingOtp;
  bool get isGuestLoading => _isGuestLoading;
  bool get isResendingOtp => _isResendingOtp;

  // ============================================================
  // ERROR
  // ============================================================

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // AUTH DATA
  // ============================================================

  String _mobile = '';
  String _verificationId = '';

  final String countryCode = '+91';

  String get mobile => _mobile;
  String get verificationId => _verificationId;

  // ============================================================
  // PHONE
  // ============================================================

  final TextEditingController phoneController =
  TextEditingController();

  bool isPhoneValid = false;

  // ============================================================
  // OTP
  // ============================================================

  final List<TextEditingController> otpControllers =
  List.generate(
    6,
        (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes =
  List.generate(
    6,
        (_) => FocusNode(),
  );

  // ============================================================
  // RESEND TIMER
  // ============================================================

  Timer? _resendTimer;

  int secondsRemaining = 30;

  bool canResend = false;

  int get resendTimer => secondsRemaining;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  AuthProvider() {
    phoneController.addListener(_validatePhone);
    _setupOtpAutoAdvance();
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================

  void _validatePhone() {
    final phone = phoneController.text.trim();

    final valid =
    RegExp(r'^[0-9]{10}$').hasMatch(phone);

    if (isPhoneValid != valid) {
      isPhoneValid = valid;
      notifyListeners();
    }

    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ============================================================
  // OTP AUTO ADVANCE
  // ============================================================

  void _setupOtpAutoAdvance() {
    for (int i = 0;
    i < otpControllers.length;
    i++) {
      otpControllers[i].addListener(() {
        final text =
            otpControllers[i].text;

        if (text.length <= 1) {
          return;
        }

        final clean =
        text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );

        if (clean.isEmpty) {
          return;
        }

        // Paste complete OTP
        if (clean.length >= 6) {
          for (int j = 0; j < 6; j++) {
            otpControllers[j].text =
            clean[j];
          }

          otpFocusNodes[5].unfocus();
          notifyListeners();
          return;
        }

        // Paste multiple digits
        for (
        int j = 0;
        j < clean.length && (i + j) < 6;
        j++
        ) {
          otpControllers[i + j].text =
          clean[j];
        }

        final nextIndex =
        (i + clean.length) < 6
            ? i + clean.length
            : 5;

        otpFocusNodes[nextIndex]
            .requestFocus();
      });
    }
  }

  // ============================================================
  // OTP INPUT
  // ============================================================

  void handleOtpInput(
      String value,
      int index,
      ) {
    if (value.isEmpty) {
      return;
    }

    final clean =
    value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (clean.isEmpty) {
      return;
    }

    otpControllers[index].text =
    clean[0];

    if (index < 5) {
      Future.delayed(
        const Duration(milliseconds: 10),
            () {
          if (otpFocusNodes[index + 1]
              .canRequestFocus) {
            otpFocusNodes[index + 1]
                .requestFocus();
          }
        },
      );
    } else {
      otpFocusNodes[index].unfocus();
    }

    notifyListeners();
  }

  // ============================================================
  // BACKSPACE
  // ============================================================

  void handleBackspace(
      String value,
      int index,
      RawKeyEvent event,
      ) {
    if (event.logicalKey ==
        LogicalKeyboardKey.backspace &&
        value.isEmpty &&
        index > 0) {
      Future.delayed(
        const Duration(milliseconds: 10),
            () {
          otpFocusNodes[index - 1]
              .requestFocus();

          final previous =
          otpControllers[index - 1];

          previous.selection =
              TextSelection(
                baseOffset: 0,
                extentOffset:
                previous.text.length,
              );
        },
      );
    }
  }

  // ============================================================
  // START RESEND TIMER
  // ============================================================

  void startResendTimer() {
    canResend = false;
    secondsRemaining = 30;

    _resendTimer?.cancel();

    notifyListeners();

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (secondsRemaining > 0) {
          secondsRemaining--;
          notifyListeners();
        } else {
          canResend = true;
          timer.cancel();
          notifyListeners();
        }
      },
    );
  }

  // ============================================================
  // GET OTP
  // ============================================================

  String getEnteredOtp() {
    return otpControllers
        .map((controller) => controller.text)
        .join();
  }

  // ============================================================
  // CLEAR OTP
  // ============================================================

  void clearOtpFields() {
    for (final controller
    in otpControllers) {
      controller.clear();
    }

    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes[0].requestFocus();
    }

    notifyListeners();
  }
// ============================================================
// SEND OTP
// ============================================================

  Future<AuthModel?> sendOtp() async {
    final phone = phoneController.text.trim();

    _errorMessage = null;

    // ----------------------------------------------------------
    // Validate mobile
    // ----------------------------------------------------------

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      _errorMessage =
      'Please enter a valid 10-digit mobile number.';
      notifyListeners();
      return null;
    }

    // ----------------------------------------------------------
    // Prevent duplicate request
    // ----------------------------------------------------------

    if (_isSendingOtp) {
      return null;
    }

    _isSendingOtp = true;
    notifyListeners();

    try {
      _mobile = phone;

      final request = AuthModel(
        mobile: _mobile,
        countryCode: countryCode,
      );

      debugPrint('========== SEND OTP ==========');
      debugPrint('MOBILE => $_mobile');

      final response =
      await _authService.sendOtp(request);

      debugPrint('SEND OTP COMPLETED');

      // --------------------------------------------------------
      // API failed
      // --------------------------------------------------------

      if (response == null) {
        _errorMessage =
        'Unable to send OTP. Please try again.';
        return null;
      }

      if (response.success != true) {
        _errorMessage =
            response.message ??
                'Unable to send OTP.';
        return response;
      }

      // --------------------------------------------------------
      // Save verification ID
      // --------------------------------------------------------

      final verificationId =
          response.verificationId;

      if (verificationId != null &&
          verificationId.isNotEmpty) {
        _verificationId = verificationId;

        debugPrint(
          'VERIFICATION ID SAVED',
        );
      } else {
        _errorMessage =
        'Verification ID not received.';
        return null;
      }

      // --------------------------------------------------------
      // Start resend timer
      // --------------------------------------------------------

      startResendTimer();

      return response;
    } catch (e) {
      debugPrint(
        'SEND OTP ERROR => $e',
      );

      _errorMessage =
          e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return null;
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

// ============================================================
// RESEND OTP
// ============================================================

  Future<bool> resendOtp() async {
    if (!canResend ||
        _mobile.isEmpty ||
        _isResendingOtp) {
      return false;
    }

    _isResendingOtp = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final request = AuthModel(
        mobile: _mobile,
        countryCode: countryCode,
      );

      debugPrint(
        '========== RESEND OTP ==========',
      );

      final response =
      await _authService.sendOtp(request);

      // --------------------------------------------------------
      // API failed
      // --------------------------------------------------------

      if (response == null) {
        _errorMessage =
        'Failed to resend OTP.';
        return false;
      }

      if (response.success != true) {
        _errorMessage =
            response.message ??
                'Failed to resend OTP.';
        return false;
      }

      // --------------------------------------------------------
      // Save NEW verification ID
      // --------------------------------------------------------

      final verificationId =
          response.verificationId;

      if (verificationId != null &&
          verificationId.isNotEmpty) {
        _verificationId = verificationId;
      } else {
        _errorMessage =
        'Verification ID not received.';
        return false;
      }

      // --------------------------------------------------------
      // Clear old OTP
      // --------------------------------------------------------

      clearOtpFields();

      // --------------------------------------------------------
      // Restart timer
      // --------------------------------------------------------

      startResendTimer();

      return true;
    } catch (e) {
      debugPrint(
        'RESEND OTP ERROR => $e',
      );

      _errorMessage =
          e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _isResendingOtp = false;
      notifyListeners();
    }
  }

// ============================================================
// VERIFY OTP
// ============================================================
  Future<AuthModel?> verifyOtp([String? customVerificationId]) async {
    final verificationId = customVerificationId ?? _verificationId;
    final otp = getEnteredOtp();

    _errorMessage = null;

    if (verificationId.isEmpty) {
      _errorMessage = 'Verification session expired. Please request a new OTP.';
      notifyListeners();
      return null;
    }

    if (otp.length != 6) {
      _errorMessage = 'Please enter complete 6-digit OTP.';
      notifyListeners();
      return null;
    }

    if (_isLoading) return null;

    _setLoading(true);

    try {
      final request = AuthModel(
        otp: otp,
        verificationId: verificationId,
      );

      debugPrint('========== VERIFY OTP ==========');
      final response = await _authService.verifyOtp(request);
      debugPrint('VERIFY OTP API COMPLETED');

      if (response == null) {
        _errorMessage = 'Unable to verify OTP. Please try again.';
        return null;
      }

      if (response.success != true) {
        _errorMessage = response.message ?? 'Invalid OTP. Please try again.';
        return response;
      }

      if (response.token == null || response.token!.isEmpty) {
        _errorMessage = 'Authentication token not received.';
        return response;
      }

      final token = response.token!;

      // 1. Persist token
      await _storageService.saveToken(token);

      // 2. Real user (never leave guest flag true)
      await _storageService.setGuestStatus(false);

      debugPrint('TOKEN SAVED SUCCESSFULLY');

      // 3. Profile check with the same token we just received
      bool profileCompleted = false;
      try {
        profileCompleted = await _authService.checkProfileCompleted(token);
        debugPrint('PROFILE COMPLETED => $profileCompleted');
      } catch (e) {
        debugPrint('PROFILE CHECK ERROR => $e');
        profileCompleted = false;
      }

      return AuthModel(
        success: true,
        message: response.message ?? 'OTP verified successfully.',
        token: token,
        verificationId: verificationId,
        isProfileCompleted: profileCompleted,
      );
    } catch (e) {
      debugPrint('VERIFY OTP ERROR => $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  // Future<AuthModel?> verifyOtp([
  //   String? customVerificationId,
  // ]) async {
  //   final verificationId =
  //       customVerificationId ?? _verificationId;
  //
  //   final otp = getEnteredOtp();
  //
  //   _errorMessage = null;
  //
  //   // ----------------------------------------------------------
  //   // Validate verification ID
  //   // ----------------------------------------------------------
  //
  //   if (verificationId.isEmpty) {
  //     _errorMessage =
  //     'Verification session expired. Please request a new OTP.';
  //     notifyListeners();
  //     return null;
  //   }
  //
  //   // ----------------------------------------------------------
  //   // Validate OTP
  //   // ----------------------------------------------------------
  //
  //   if (otp.length != 6) {
  //     _errorMessage =
  //     'Please enter complete 6-digit OTP.';
  //     notifyListeners();
  //     return null;
  //   }
  //
  //   // ----------------------------------------------------------
  //   // Prevent duplicate request
  //   // ----------------------------------------------------------
  //
  //   if (_isLoading) {
  //     return null;
  //   }
  //
  //   _setLoading(true);
  //
  //   try {
  //     final request = AuthModel(
  //       otp: otp,
  //       verificationId: verificationId,
  //     );
  //
  //     debugPrint(
  //       '========== VERIFY OTP ==========',
  //     );
  //
  //     final response =
  //     await _authService.verifyOtp(request);
  //
  //     debugPrint(
  //       'VERIFY OTP API COMPLETED',
  //     );
  //
  //     // --------------------------------------------------------
  //     // API failed
  //     // --------------------------------------------------------
  //
  //     if (response == null) {
  //       _errorMessage =
  //       'Unable to verify OTP. Please try again.';
  //       return null;
  //     }
  //
  //     // --------------------------------------------------------
  //     // Invalid OTP / token missing
  //     // --------------------------------------------------------
  //
  //     if (response.success != true) {
  //       _errorMessage =
  //           response.message ??
  //               'Invalid OTP. Please try again.';
  //       return response;
  //     }
  //
  //     if (response.token == null ||
  //         response.token!.isEmpty) {
  //       _errorMessage =
  //       'Authentication token not received.';
  //       return response;
  //     }
  //
  //     // --------------------------------------------------------
  //     // Save token
  //     // --------------------------------------------------------
  //
  //     final token = response.token!;
  //
  //     await _storageService.saveToken(token);
  //
  //     // Real user
  //     await _storageService.setGuestStatus(false);
  //
  //     debugPrint(
  //       'TOKEN SAVED SUCCESSFULLY',
  //     );
  //
  //     // --------------------------------------------------------
  //     // Check existing profile
  //     // --------------------------------------------------------
  //
  //     bool profileCompleted = false;
  //
  //     try {
  //       profileCompleted =
  //       await _authService.checkProfileCompleted(
  //         token,
  //       );
  //
  //       debugPrint(
  //         'PROFILE COMPLETED => $profileCompleted',
  //       );
  //     } catch (e) {
  //       debugPrint(
  //         'PROFILE CHECK ERROR => $e',
  //       );
  //
  //       // If profile check fails,
  //       // treat as incomplete profile.
  //       profileCompleted = false;
  //     }
  //
  //     // --------------------------------------------------------
  //     // Return final authentication result
  //     // --------------------------------------------------------
  //
  //     return AuthModel(
  //       success: true,
  //       message:
  //       response.message ??
  //           'OTP verified successfully.',
  //       token: token,
  //       verificationId: verificationId,
  //       isProfileCompleted:
  //       profileCompleted,
  //     );
  //   } catch (e) {
  //     debugPrint(
  //       'VERIFY OTP ERROR => $e',
  //     );
  //
  //     _errorMessage =
  //         e.toString().replaceFirst(
  //           'Exception: ',
  //           '',
  //         );
  //
  //     return null;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }
  // ============================================================
  // CONTINUE AS GUEST
  // ============================================================

  Future<bool> continueAsGuest() async {
    if (_isGuestLoading) {
      return false;
    }

    _isGuestLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _storageService.setGuestStatus(
        true,
      );

      debugPrint(
        'CONTINUE AS GUEST => SUCCESS',
      );

      return true;
    } catch (e) {
      debugPrint(
        'CONTINUE AS GUEST ERROR => $e',
      );

      _errorMessage =
      'Unable to continue as guest. Please try again.';

      return false;
    } finally {
      _isGuestLoading = false;
      notifyListeners();
    }
  }

  bool _isProfileCompletedFromUser(Map<String, dynamic> user) {
    final fullName = user['fullName']?.toString().trim() ?? '';
    final dob = user['dob']?.toString().trim() ?? '';
    final mobile = user['mobile']?.toString().trim() ?? '';
    final email = user['email']?.toString().trim() ?? '';
    final address = user['address']?.toString().trim() ?? '';

    return fullName.isNotEmpty &&
        dob.isNotEmpty &&
        mobile.isNotEmpty &&
        email.isNotEmpty &&
        address.isNotEmpty;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<bool> logout() async {
    if (_isLoading) return false;

    _setLoading(true);

    try {
      await _storageService.clearSession();          // removes token + guest
      await _storageService.setGuestStatus(false);   // explicit – never leave true

      phoneController.clear();
      _mobile = '';
      isPhoneValid = false;

      clearOtpFields();
      for (final focusNode in otpFocusNodes) {
        focusNode.unfocus();
      }

      _verificationId = '';

      _resendTimer?.cancel();
      _resendTimer = null;
      secondsRemaining = 30;
      canResend = false;

      _isSendingOtp = false;
      _isResendingOtp = false;
      _isGuestLoading = false;
      _errorMessage = null;

      debugPrint('LOGOUT => PHONE + OTP + SESSION CLEARED');
      return true;
    } catch (e) {
      debugPrint('LOGOUT ERROR => $e');
      _errorMessage = 'Logout failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // COMMON LOADING
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;

    if (value) {
      _errorMessage = null;
    }

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    phoneController.dispose();

    for (final controller
    in otpControllers) {
      controller.dispose();
    }

    for (final focusNode
    in otpFocusNodes) {
      focusNode.dispose();
    }

    _resendTimer?.cancel();

    super.dispose();
  }
}