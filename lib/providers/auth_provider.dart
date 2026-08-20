import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/Model/auth_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _mobile = '';
  String _verificationId = '';
  final String countryCode = "+91";

  String get mobile => _mobile;
  String get verificationId => _verificationId;

  final TextEditingController phoneController = TextEditingController();
  bool isPhoneValid = false;

  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int secondsRemaining = 30;
  bool canResend = false;

  int get resendTimer => secondsRemaining;

  AuthProvider() {
    phoneController.addListener(_validatePhone);
    _setupOtpAutoAdvance();
  }

  void _validatePhone() {
    final phone = phoneController.text.trim();
    final valid = RegExp(r'^[0-9]{10}$').hasMatch(phone);
    if (isPhoneValid != valid) {
      isPhoneValid = valid;
      notifyListeners();
    }
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setupOtpAutoAdvance() {
    for (int i = 0; i < otpControllers.length; i++) {
      otpControllers[i].addListener(() {
        final text = otpControllers[i].text;
        if (text.length > 1) {
          final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.isEmpty) return;
          if (clean.length >= 6) {
            for (int j = 0; j < 6; j++) {
              otpControllers[j].text = clean[j];
            }
            otpFocusNodes[5].unfocus();
          } else {
            for (int j = 0; j < clean.length && (i + j) < 6; j++) {
              otpControllers[i + j].text = clean[j];
            }
            final nextIndex = (i + clean.length) < 6 ? (i + clean.length) : 5;
            otpFocusNodes[nextIndex].requestFocus();
          }
        }
      });
    }
  }

  void handleOtpInput(String value, int index) {
    if (value.isNotEmpty) {
      otpControllers[index].text = value;
      if (index < 5) {
        Future.delayed(const Duration(milliseconds: 10), () {
          otpFocusNodes[index + 1].requestFocus();
        });
      } else {
        otpFocusNodes[index].unfocus();
      }
    }
  }

  void handleBackspace(String value, int index, RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.backspace && value.isEmpty && index > 0) {
      Future.delayed(const Duration(milliseconds: 10), () {
        otpFocusNodes[index - 1].requestFocus();
        otpControllers[index - 1].selection = TextSelection(
          baseOffset: 0,
          extentOffset: otpControllers[index - 1].text.length,
        );
      });
    }
  }

  void startResendTimer() {
    canResend = false;
    secondsRemaining = 30;
    _resendTimer?.cancel();
    notifyListeners();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      } else {
        canResend = true;
        _resendTimer?.cancel();
        notifyListeners();
      }
    });
  }

  String getEnteredOtp() => otpControllers.map((e) => e.text).join();

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes[0].requestFocus();
    }
  }

  Future<AuthModel?> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.length != 10) {
      _errorMessage = "Please enter a valid 10-digit mobile number.";
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      _mobile = phone;
      final req = AuthModel(mobile: _mobile, countryCode: countryCode);
      final res = await _authService.sendOtp(req);

      if (res != null) {
        if (res.verificationId != null && res.verificationId!.isNotEmpty) {
          _verificationId = res.verificationId!;
        }
        if (res.token != null && res.token!.isNotEmpty) {
          await _storageService.saveToken(res.token!);
        }
        startResendTimer();
      }
      return res;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendOtp() async {
    if (!canResend || _mobile.isEmpty) return false;

    _setLoading(true);
    try {
      final req = AuthModel(mobile: _mobile, countryCode: countryCode);
      final res = await _authService.sendOtp(req);

      if (res != null && res.success) {
        if (res.verificationId != null && res.verificationId!.isNotEmpty) {
          _verificationId = res.verificationId!;
        }
        clearOtpFields();
        startResendTimer();
        return true;
      }
      _errorMessage = res?.message ?? "Failed to resend OTP";
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthModel?> verifyOtp([String? customVerificationId]) async {
    final targetVerificationId = customVerificationId ?? _verificationId;
    final otp = getEnteredOtp();

    if (targetVerificationId.isEmpty) {
      _errorMessage = "Verification ID not found.";
      notifyListeners();
      return null;
    }

    if (otp.length != 6) {
      _errorMessage = "Please enter complete 6-digit OTP";
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      final req = AuthModel(otp: otp, verificationId: targetVerificationId);
      final res = await _authService.verifyOtp(req);

      if (res != null && res.success && res.token != null) {
        await _storageService.saveToken(res.token!);
        await _storageService.setGuestStatus(false);

        final isCompleted = await _authService.checkProfileCompleted(res.token!);

        return AuthModel(
          success: res.success,
          message: res.message,
          token: res.token,
          verificationId: targetVerificationId,
          isProfileCompleted: isCompleted,
        );
      } else {
        _errorMessage = res?.message ?? "Invalid OTP, please try again.";
        return res;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> continueAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.setGuestStatus(true);

      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      debugPrint(
        'CONTINUE AS GUEST ERROR => $_errorMessage',
      );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    try {
      await _storageService.clearSession();
      phoneController.clear();
      clearOtpFields();
      isPhoneValid = false;
      _errorMessage = null;
      _mobile = '';
      _verificationId = '';
      return true;
    } catch (e) {
      _errorMessage = "Logout failed: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }


}