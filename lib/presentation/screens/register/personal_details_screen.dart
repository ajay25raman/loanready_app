import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loanready_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUserData();
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(UserProvider provider) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      provider.dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
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
                                  color: const Color(0xFFC9A227),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A227).withAlpha(25),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text("Step 1/3", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC9A227))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (provider.isFetchingData)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFFC9A227)))),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          children: [
                            _buildModernField(
                              label: "Full Name",
                              controller: provider.nameController,
                              icon: Icons.person_outline_rounded,
                              validator: _validateName,
                              isLoading: provider.isFetchingData,
                            ),
                            const SizedBox(height: 20),
                            _buildModernField(
                              label: "Date of Birth",
                              controller: provider.dobController,
                              icon: Icons.cake_outlined,
                              validator: _validateDOB,
                              isLoading: provider.isFetchingData,
                              readOnly: true,
                              onTap: () => _selectDob(provider),
                            ),
                            const SizedBox(height: 20),
                            _buildModernField(
                              label: "Mobile Number",
                              controller: provider.phoneController,
                              icon: Icons.phone_android_rounded,
                              validator: _validatePhone,
                              isPhone: true,
                              isLoading: provider.isFetchingData,
                            ),
                            const SizedBox(height: 20),
                            _buildModernField(
                              label: "Email Address",
                              controller: provider.emailController,
                              icon: Icons.email_outlined,
                              validator: _validateEmail,
                              isLoading: provider.isFetchingData,
                            ),
                            const SizedBox(height: 20),
                            _buildModernField(
                              label: "Address",
                              controller: provider.addressController,
                              icon: Icons.home_outlined,
                              validator: _validateAddress,
                              maxLines: 2,
                              isLoading: provider.isFetchingData,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A227),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                          ),
                          onPressed: (provider.isLoading || provider.isFetchingData)
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              final res = await provider.saveUserDetails();
                              if (!context.mounted) return;
                              _showSnackBar(res['message'], res['success'] ? Colors.green : Colors.red);
                              if (res['success']) {
                                Navigator.pushReplacementNamed(context, '/businessDetails');
                              }
                            }
                          },
                          child: provider.isLoading
                              ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text("Save & Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?)? validator,
    bool isPhone = false,
    bool isLoading = false,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFC9A227)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isLoading ? Colors.grey.shade500 : const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: !isLoading,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          maxLength: isPhone ? 10 : null,
          decoration: InputDecoration(
            counterText: '',
            prefixText: isPhone ? '+91  ' : null,
            filled: true,
            fillColor: isLoading ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFC9A227), width: 2)),
            suffixIcon: readOnly ? const Icon(Icons.calendar_month_outlined, color: Color(0xFFC9A227)) : null,
          ),
        ),
      ],
    );
  }
}