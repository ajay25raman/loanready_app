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

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingData = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  static const String baseUrl = "https://loan-approval-api-faur.onrender.com/api/v1";

  // Animation controllers for subtle fade-in
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ====================== API & HELPERS (unchanged logic) ======================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return;

      setState(() => _isFetchingData = true);

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apiDob = data['dob']?.toString() ?? '';

        String formattedDob = '';
        if (apiDob.isNotEmpty) {
          try {
            final date = DateFormat('yyyy-MM-dd').parse(apiDob);
            formattedDob = DateFormat('dd/MM/yyyy').format(date);
          } catch (_) {
            formattedDob = apiDob;
          }
        }

        setState(() {
          nameController.text = data['fullName']?.toString() ?? '';
          dobController.text = formattedDob;
          phoneController.text = data['mobile']?.toString().replaceAll('+91', '').trim() ?? '';
          emailController.text = data['email']?.toString() ?? '';
          addressController.text = data['address']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      setState(() => _isFetchingData = false);
    }
  }

  Future<void> _saveUserDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _showSnackBar('Authentication token not found!', Colors.red);
        return;
      }

      String apiDobFormat = '';
      if (dobController.text.trim().isNotEmpty) {
        try {
          final date = DateFormat('dd/MM/yyyy').parse(dobController.text.trim());
          apiDobFormat = DateFormat('yyyy-MM-dd').format(date);
        } catch (_) {
          apiDobFormat = dobController.text.trim();
        }
      }

      final requestBody = {
        "fullName": nameController.text.trim(),
        "dob": apiDobFormat,
        "mobile": "+91${phoneController.text.trim()}",
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Details saved successfully!', Colors.green);
        Navigator.pushNamed(context, '/businessDetails');
      } else {
        final errorData = json.decode(response.body);
        _showSnackBar(errorData['message'] ?? 'Failed to save details', Colors.red);
      }
    } catch (error) {
      _showSnackBar('Something went wrong: $error', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // ====================== VALIDATORS (same as yours) ======================
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) return 'Only alphabets allowed';
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date of birth is required';
    if (!RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}$').hasMatch(value.trim())) {
      return 'Enter date in DD/MM/YYYY format';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) return 'Enter valid 10-digit mobile number';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Address is required';
    if (value.trim().length < 10) return 'Please enter a complete address';
    return null;
  }

  // ====================== MAIN BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // soft background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
          color: const Color(0xFF1E293B),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Personal Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Progress Card (modern) ----------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: 1 / 3,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFFC9A227), // your gold accent
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A227).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Step 1/3",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFFC9A227),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ---------- Loading state ----------
                  if (_isFetchingData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Color(0xFFC9A227)),
                      ),
                    ),

                  // ---------- Main Form Card (elevated, soft corners) ----------
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildModernField(
                            label: "Full Name",
                            controller: nameController,
                            icon: Icons.person_outline_rounded,
                            validator: _validateName,
                            isLoading: _isFetchingData,
                          ),
                          const SizedBox(height: 20),
                          _buildModernField(
                            label: "Date of Birth",
                            controller: dobController,
                            icon: Icons.cake_outlined,
                            validator: _validateDOB,
                            isLoading: _isFetchingData,
                          ),
                          const SizedBox(height: 20),
                          _buildModernField(
                            label: "Mobile Number",
                            controller: phoneController,
                            icon: Icons.phone_android_rounded,
                            validator: _validatePhone,
                            isPhone: true,
                            isLoading: _isFetchingData,
                          ),
                          const SizedBox(height: 20),
                          _buildModernField(
                            label: "Email Address",
                            controller: emailController,
                            icon: Icons.email_outlined,
                            validator: _validateEmail,
                            isLoading: _isFetchingData,
                          ),
                          const SizedBox(height: 20),
                          _buildModernField(
                            label: "Address",
                            controller: addressController,
                            icon: Icons.home_outlined,
                            validator: _validateAddress,
                            maxLines: 2,
                            isLoading: _isFetchingData,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---------- Premium Button with gold gradient ----------
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A227),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFFC9A227).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: (_isLoading || _isFetchingData) ? null : _saveUserDetails,
                      child: _isLoading
                          ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text("Save & Continue"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====================== REUSABLE MODERN INPUT FIELD ======================
  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?)? validator,
    bool isPhone = false,
    bool isLoading = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFC9A227)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isLoading ? Colors.grey.shade500 : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: !isLoading,
          maxLines: maxLines,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          maxLength: isPhone ? 10 : null,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            counterText: '',
            prefixText: isPhone ? '+91  ' : null,
            hintText: isPhone ? "98765 43210" : null,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: isLoading ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFC9A227), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}