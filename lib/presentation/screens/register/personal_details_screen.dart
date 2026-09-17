import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loanready_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // IMPORTANT:
    // Do NOT call fetchUserData() here.
    // OTP verification already decides:
    // Existing user -> Home
    // New user -> Personal Details

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDob(UserProvider provider) async {
    FocusScope.of(context).unfocus();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      provider.dobController.text =
          DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
      String message,
      Color color,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(
            milliseconds: 800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Full name is required';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
      return 'Only alphabets allowed';
    }

    return null;
  }

  String? _validateDOB(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Date of birth is required';
    }

    if (!RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])/'
      r'(0[1-9]|1[0-2])/'
      r'[0-9]{4}$',
    ).hasMatch(text)) {
      return 'Enter date in DD/MM/YYYY format';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Mobile number is required';
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
      return 'Enter valid 10-digit mobile number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(text)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validateAddress(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Address is required';
    }

    if (text.length < 10) {
      return 'Please enter a complete address';
    }

    return null;
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveDetails(UserProvider provider) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await provider.saveUserDetails();

    if (!mounted) return;

    if (result['success'] == true) {
      // Success message
      _showSnackBar(
        'Personal details added successfully.',
        Colors.green,
      );

      // Small delay so user can see the message
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/businessDetails',
      );

      return;
    }

    _showSnackBar(
      result['message']?.toString() ??
          'Failed to save personal details.',
      Colors.red,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
          ),
          color: const Color(0xFF1E293B),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Personal Details',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ),

      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                24,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // ==================================================
                      // PROGRESS
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(12),
                                child:
                                const LinearProgressIndicator(
                                  value: 1 / 3,
                                  minHeight: 8,
                                  backgroundColor:
                                  Color(0xFFE5E7EB),
                                  color: Color(0xFFC9A227),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC9A227,
                                ).withAlpha(25),
                                borderRadius:
                                BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'Step 1/3',
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w700,
                                  color:
                                  Color(0xFFC9A227),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // FORM
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            _buildModernField(
                              label: 'Full Name',
                              controller:
                              provider.nameController,
                              icon:
                              Icons.person_outline_rounded,
                              validator: _validateName,
                            ),

                            const SizedBox(height: 18),

                            _buildModernField(
                              label: 'Date of Birth',
                              controller:
                              provider.dobController,
                              icon:
                              Icons.cake_outlined,
                              validator: _validateDOB,
                              readOnly: true,
                              onTap: () =>
                                  _selectDob(provider),
                            ),

                            const SizedBox(height: 18),

                            _buildModernField(
                              label: 'Mobile Number',
                              controller:
                              provider.phoneController,
                              icon:
                              Icons.phone_android_rounded,
                              validator: _validatePhone,
                              isPhone: true,
                            ),

                            const SizedBox(height: 18),

                            _buildModernField(
                              label: 'Email Address',
                              controller:
                              provider.emailController,
                              icon:
                              Icons.email_outlined,
                              validator: _validateEmail,
                            ),

                            const SizedBox(height: 18),

                            _buildModernField(
                              label: 'Address',
                              controller:
                              provider.addressController,
                              icon:
                              Icons.home_outlined,
                              validator: _validateAddress,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ==================================================
                      // SAVE BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _saveDetails(
                            provider,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFC9A227),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                            Colors.grey.shade400,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save & Continue',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 21,
                              ),
                            ],
                          ),
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

  // ============================================================
  // FIELD
  // ============================================================

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?)? validator,
    bool isPhone = false,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFFC9A227),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: isPhone
              ? TextInputType.phone
              : TextInputType.text,
          maxLength: isPhone ? 10 : null,

          decoration: InputDecoration(
            counterText: '',
            prefixText: isPhone ? '+91  ' : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),
              borderSide:
              const BorderSide(
                color: Color(0xFFC9A227),
                width: 1.5,
              ),
            ),

            errorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),
              borderSide:
              const BorderSide(
                color: Colors.red,
              ),
            ),

            focusedErrorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(18),
              borderSide:
              const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),

            suffixIcon: readOnly
                ? const Icon(
              Icons
                  .calendar_month_outlined,
              color: Color(0xFFC9A227),
            )
                : null,
          ),
        ),
      ],
    );
  }
}