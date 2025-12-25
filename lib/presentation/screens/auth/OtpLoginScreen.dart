import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'VerifyOtpScreen.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  String? errorText;
  bool isPhoneValid = false;


  final String countryCode = "+91";

  final String baseUrl =
      "https://loan-approval-api-faur.onrender.com/api/v1";

  void validatePhoneNumber() {
    setState(() {
      isPhoneValid = phoneController.text.isNotEmpty &&
          RegExp(r'^\d+$').hasMatch(phoneController.text);
    });
  }

  Future<void> sendOtp() async {
    final phoneNumber = phoneController.text.trim();

    if (!isPhoneValid) return;

    setState(() {
      errorText = null;
      isLoading = true;
    });

    try {
      final url = Uri.parse("$baseUrl/otp/send");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "countryCode": countryCode,
          "mobile": phoneNumber,
          "templateId":"register"
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final verificationId = responseData["verificationId"];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifyOtpScreen(),
            settings: RouteSettings(
              arguments: {
                "mobile": phoneNumber,
                "verificationId": verificationId,
                "countryCode": countryCode,
              },
            ),
          ),
        );
      } else {
        setState(() {
          errorText = responseData["message"] ?? "Something went wrong";
        });
      }
    } catch (e) {
      setState(() {
        errorText = "Something went wrong: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onPhoneNumberChanged(String value) {
    if (errorText != null) {
      setState(() {
        errorText = null;
      });
    }

    validatePhoneNumber();
  }

  @override
  void initState() {
    super.initState();
    phoneController.addListener(() {
      _onPhoneNumberChanged(phoneController.text);
      validatePhoneNumber();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Image.network(
                  'https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-83.jpg?w=826',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

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
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(
                    color:
                    errorText != null ? Colors.red : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            '🇮🇳',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '+91',
                            style: TextStyle(
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
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
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
                          errorText: null,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onPhoneNumberChanged,
                      ),
                    ),
                  ],
                ),
              ),

              if (errorText != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (isLoading || !isPhoneValid) ? null : sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPhoneValid
                        ? const Color(0xFF1A237E)
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      color: isPhoneValid
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
