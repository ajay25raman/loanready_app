import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingData = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // API Endpoints
  static const String baseUrl = "https://loan-approval-api-faur.onrender.com/api/v1";
  static const String otp = "123456"; // Static OTP (aapne bola tha)

  @override
  void initState() {
    super.initState();
    // Jab screen load ho, toh automatically user data fetch karo
    _fetchUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Token get karne ke liye helper function
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // API 1: Get User Details (Fetch data from API)
  Future<void> _fetchUserData() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        // Agar token nahi hai, toh user se data input karne do
        return;
      }

      setState(() {
        _isFetchingData = true;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Format change karo: API se "2002-02-15" aa raha hai, UI mein "15/02/2002" show karna hai
        final apiDob = data['dob']?.toString() ?? '';
        String formattedDob = '';

        if (apiDob.isNotEmpty) {
          try {
            final inputFormat = DateFormat('yyyy-MM-dd');
            final outputFormat = DateFormat('dd/MM/yyyy');
            final date = inputFormat.parse(apiDob);
            formattedDob = outputFormat.format(date);
          } catch (e) {
            formattedDob = apiDob;
          }
        }

        // Data controllers mein set karo
        setState(() {
          nameController.text = data['fullName']?.toString() ?? '';
          dobController.text = formattedDob;
          phoneController.text = data['mobile']?.toString().replaceAll('+91', '').trim() ?? '';
          emailController.text = data['email']?.toString() ?? '';
          addressController.text = data['address']?.toString() ?? '';
        });
      } else {
        // Agar error aaye, toh kuch nahi karo - user khud se data input karega
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setState(() {
        _isFetchingData = false;
      });
    }
  }

  // API 2: Save User Details (Post data to API)
  Future<void> _saveUserDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Format change karo: UI se "15/02/2002" aa raha hai, API mein "2002-02-15" bhejna hai
      String apiDobFormat = '';
      final uiDob = dobController.text.trim();

      if (uiDob.isNotEmpty) {
        try {
          final inputFormat = DateFormat('dd/MM/yyyy');
          final outputFormat = DateFormat('yyyy-MM-dd');
          final date = inputFormat.parse(uiDob);
          apiDobFormat = outputFormat.format(date);
        } catch (e) {
          // Agar format wrong hai toh raw value hi bhej do
          apiDobFormat = uiDob;
        }
      }

      // Request body prepare karo
      final requestBody = {
        "fullName": nameController.text.trim(),
        "dob": apiDobFormat,
        "mobile": "+91${phoneController.text.trim()}",
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
      };

      // API call for saving user details
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved Successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Next screen par navigate karo
        if (_formKey.currentState!.validate()) {
          Navigator.pushNamed(context, '/businessDetails');
        }

      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${errorData['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Validation functions (same as before)
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
      return 'Only alphabets allowed';
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter DOB';
    if (!RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}$')
        .hasMatch(value.trim())) {
      return 'Enter valid format DD/MM/YYYY';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }

    String phone = value.trim();
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter valid email';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: LinearProgressIndicator(
                            value: 0.33,
                            backgroundColor: Colors.grey.shade300,
                            color: const Color(0xFF1A237E),
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '33%',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Loading indicator jab data fetch ho raha ho
                    if (_isFetchingData)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),

                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name*',
                      hint: 'Ramesh Kumar',
                      validator: _validateName,
                      isLoading: _isFetchingData,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: dobController,
                      label: 'DOB*',
                      hint: '20/10/1997',
                      validator: _validateDOB,
                      isLoading: _isFetchingData,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Mobile Number*',
                      hint: '9876543210',
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      isPhoneField: true,
                      isLoading: _isFetchingData,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email Address*',
                      hint: 'rameshkirana@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      isLoading: _isFetchingData,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: addressController,
                      label: 'Address*',
                      hint: 'Patna, Bihar',
                      validator: _validateAddress,
                      isLoading: _isFetchingData,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002D72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading || _isFetchingData
                            ? null
                            : () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushNamed(context, '/businessDetails');
                          }
                        },

                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPhoneField = false,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isLoading ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: isPhoneField ? 10 : null,
          enabled: !isLoading,
          decoration: InputDecoration(
            prefixText: isPhoneField ? '+91 ' : null,
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(color: isLoading ? Colors.grey : Colors.black54),
            filled: true,
            fillColor: isLoading ? Colors.grey[100] : const Color(0xFFF5F7FA),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: isLoading ? Colors.grey[300]! : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}