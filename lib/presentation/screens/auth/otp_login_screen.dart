import 'package:flutter/material.dart';
import 'package:loanready_app/providers/auth_provider.dart';
import 'package:loanready_app/routes/app_routes.dart';
import 'package:provider/provider.dart';

import 'verify_otp_screen.dart';

class OtpLoginScreen extends StatelessWidget {
  const OtpLoginScreen({super.key});

  void _showSnackBar(
      BuildContext context,
      String message,
      Color color,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // =========================================================
                  // IMAGE
                  // =========================================================

                  Center(
                    child: Image.network(
                      'https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-83.jpg?w=826',
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const SizedBox(
                          height: 250,
                          child: Icon(
                            Icons.phone_android_rounded,
                            size: 100,
                            color: Color(0xFF1A237E),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================================================
                  // TITLE
                  // =========================================================

                  const Text(
                    'Enter your phone number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "We'll send you a text verification code.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =========================================================
                  // PHONE INPUT
                  // =========================================================

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: auth.errorMessage != null
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '🇮🇳',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                auth.countryCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: auth.phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter 10-digit number',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =========================================================
                  // ERROR MESSAGE
                  // =========================================================

                  if (auth.errorMessage != null &&
                      auth.errorMessage!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        auth.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // =========================================================
                  // SEND OTP BUTTON
                  // =========================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (auth.isSendingOtp || !auth.isPhoneValid)
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();

                        final result = await auth.sendOtp();

                        if (!context.mounted) return;

                        if (result != null && result.success == true) {
                          _showSnackBar(
                            context,
                            'OTP sent successfully.',
                            Colors.green,
                          );

                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          if (!context.mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VerifyOtpScreen(),
                            ),
                          );
                        } else {
                          _showSnackBar(
                            context,
                            auth.errorMessage ??
                                'Unable to send OTP. Please try again.',
                            Colors.red,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: auth.isPhoneValid
                            ? const Color(0xFF1A237E)
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      child: auth.isSendingOtp
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Send OTP',
                        style: TextStyle(
                          fontSize: 16,
                          color: auth.isPhoneValid
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =========================================================
                  // OR
                  // =========================================================

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =========================================================
                  // GUEST BUTTON
                  // =========================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: auth.isGuestLoading
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();

                        final success =
                        await auth.continueAsGuest();

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          );
                        } else {
                          _showSnackBar(
                            context,
                            auth.errorMessage ??
                                'Unable to continue as guest.',
                            Colors.red,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A237E),
                        disabledForegroundColor:
                        const Color(0xFF1A237E).withOpacity(0.6),
                        side: const BorderSide(
                          color: Color(0xFF1A237E),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: auth.isGuestLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A237E),
                          ),
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Continue as Guest',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}