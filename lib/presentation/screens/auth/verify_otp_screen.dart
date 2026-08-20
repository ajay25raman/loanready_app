import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../register/personal_details_screen.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Widget _buildOtpBox(BuildContext context, AuthProvider auth, int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            auth.handleBackspace(auth.otpControllers[index].text, index, event);
          }
        },
        child: TextField(
          controller: auth.otpControllers[index],
          focusNode: auth.otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: auth.otpFocusNodes[index].hasFocus ? Colors.blue.shade50 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => auth.handleOtpInput(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Image.network(
                    "https://img.freepik.com/free-vector/two-factor-authentication-concept-illustration_114360-5488.jpg",
                    height: 220,
                  ),
                  const SizedBox(height: 30),
                  const Text("Verify OTP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text("We've sent a verification code to", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("${auth.countryCode} ${auth.mobile}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => _buildOtpBox(context, auth, index)),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                        final result = await auth.verifyOtp();

                        if (!context.mounted) return;

                        if (result != null && result.success) {
                          _showSnackBar(context, result.message ?? "OTP Verified Successfully", Colors.green);

                          if (result.isProfileCompleted) {
                            Navigator.pushReplacementNamed(context, "/home");
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
                            );
                          }
                        } else {
                          _showSnackBar(context, auth.errorMessage ?? "Verification failed", Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Verify OTP", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive OTP?", style: TextStyle(fontSize: 15)),
                      TextButton(
                        onPressed: auth.canResend
                            ? () async {
                          final success = await auth.resendOtp();

                          if (!context.mounted) return;

                          if (success) {
                            _showSnackBar(context, "OTP Resent Successfully", const Color(0xFF1A237E));
                          } else {
                            _showSnackBar(context, auth.errorMessage ?? "Failed to resend OTP", Colors.red);
                          }
                        }
                            : null,
                        child: Text(
                          auth.canResend ? "Resend OTP" : "Resend in ${auth.resendTimer}s",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}