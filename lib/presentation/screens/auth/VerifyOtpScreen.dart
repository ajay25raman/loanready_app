import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../register/register_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 30;
  Timer? _timer;

  final String baseUrl = "https://loan-approval-api-faur.onrender.com/api/v1";

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });


    _setupOtpListeners();
  }

  void _setupOtpListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        final text = _otpControllers[i].text;

        // Paste handling
        if (text.length > 1) {
          final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.isEmpty) return;

          if (clean.length >= 6) {
            for (int j = 0; j < 6; j++) {
              _otpControllers[j].text = clean[j];
            }
            _focusNodes[5].requestFocus();
            _focusNodes[5].unfocus();
          } else {
            for (int j = 0; j < clean.length && (i + j) < 6; j++) {
              _otpControllers[i + j].text = clean[j];
            }
            final nextIndex = (i + clean.length) < 6 ? (i + clean.length) : 5;
            _focusNodes[nextIndex].requestFocus();
          }
          return;
        }
      });
    }
  }

  void _handleOtpInput(String value, int index) {

    if (value.isNotEmpty) {
      _otpControllers[index].text = value; // Set the digit


      if (index < 5) {
        Future.delayed(const Duration(milliseconds: 10), () {
          _focusNodes[index + 1].requestFocus();
        });
      } else {
        // If last field, unfocus
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handleBackspace(String value, int index, RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.backspace && value.isEmpty) {
      if (index > 0) {
        Future.delayed(const Duration(milliseconds: 10), () {
          _focusNodes[index - 1].requestFocus();
          _otpControllers[index - 1].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index - 1].text.length,
          );
        });
      }
    }
  }

  void _startTimer() {
    _canResend = false;
    _resendTimer = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendTimer == 0) {
        setState(() {
          _canResend = true;
        });
        t.cancel();
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final phone = args?["mobile"];
    final verificationId = args?["verificationId"];

    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter complete 6-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("$baseUrl/otp/verify");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "verificationId": verificationId,
          "otp": otp,
        }),
      );

      Map<String, dynamic>? data;
      final bodyTrim = response.body.trim();
      final contentType = response.headers['content-type'] ?? '';

      if (contentType.contains('application/json') ||
          bodyTrim.startsWith('{') ||
          bodyTrim.startsWith('[')) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          data = null;
        }
      }

      if (response.statusCode == 200 && data != null) {
        final token = data["token"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP Verified Successfully"),
            backgroundColor: Color(0xFF1A237E),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RegisterScreen(),
            settings: RouteSettings(arguments: {
              "mobile": phone,
              "token": token,
            }),
          ),
        );
      } else {
        final msg = (data != null && data['message'] != null)
            ? data['message']
            : (bodyTrim.isNotEmpty ? bodyTrim : 'Invalid OTP or server error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final phone = args?["mobile"];

    try {
      final url = Uri.parse("$baseUrl/otp/send");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "countryCode": "+91",
          "mobile": phone,
          "templateId": "register",
        }),
      );

      if (response.statusCode == 200) {
        _startTimer();
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP Resent Successfully"),
            backgroundColor: Color(0xFF1A237E),
          ),
        );
      } else {
        String msg = 'Failed to resend OTP';
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? msg;
        } catch (_) {
          if (response.body.trim().isNotEmpty) msg = response.body.trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to resend: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleBackspace(_otpControllers[index].text, index, event);
          }
        },
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: _focusNodes[index].hasFocus
                ? Colors.blue.shade50
                : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFF1A237E),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _handleOtpInput(value, index);
            }
          },
          onTap: () {
            _otpControllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _otpControllers[index].text.length,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final mobile = args?['mobile'] ?? "0000000000";
    final formattedMobile = mobile.length >= 10
        ? '+91 ${mobile.substring(0, 5)} ${mobile.substring(5)}'
        : '+91 $mobile';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        splashRadius: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateTime.now().hour.toString().padLeft(2, '0') +
                          ':' +
                          DateTime.now().minute.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue.shade50,
                  ),
                  child: Center(
                    child: Image.network(
                      'https://img.freepik.com/free-vector/enter-otp-concept-illustration_114360-7897.jpg?w=826',
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'Verify Code',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 12),
                Column(
                  children: [
                    Text(
                      "Verification code has been sent to",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      formattedMobile,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpBox(index)),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _canResend ? _resendCode : null,
                      child: Text(
                        _canResend ? "Resend Now" : "Resend in $_resendTimer s",
                        style: TextStyle(
                          color: _canResend ? Colors.blue.shade600 : Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue.shade200,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Verify & Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    for (var controller in _otpControllers) {
                      controller.clear();
                    }
                    _focusNodes[0].requestFocus();
                  },
                  child: const Text(
                    'Clear OTP',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}