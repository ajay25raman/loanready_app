// ─────────────────────────────────────────────────────────────────────────────
// EDIT PROFILE SCREEN — UserProvider Based
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loanready_app/Model/user_profile_model.dart';
import 'package:loanready_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;

  File? _selectedImage;
  String? _uploadedPhotoUrl;

  bool _isSaving = false;
  bool _isGuest = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _checkGuestAndFillData();
  }

  // ===========================================================================
  // CHECK GUEST + PREFILL
  // ===========================================================================

  Future<void> _checkGuestAndFillData() async {
    final prefs =
    await SharedPreferences.getInstance();

    final isGuest =
        prefs.getBool('is_guest') ?? false;

    if (!mounted) return;

    setState(() {
      _isGuest = isGuest;

      if (_isGuest) {
        // ----------------------------------------------------------
        // Guest
        // ----------------------------------------------------------

        _nameController =
            TextEditingController(
              text: prefs.getString('guest_name') ??
                  widget.profile.fullName ??
                  '',
            );

        _mobileController =
            TextEditingController(
              text: prefs.getString('guest_phone') ??
                  '',
            );

        _emailController =
            TextEditingController(
              text: prefs.getString('guest_email') ??
                  '',
            );

        _dobController =
            TextEditingController(
              text: prefs.getString('guest_dob') ??
                  '',
            );

        _addressController =
            TextEditingController(
              text: prefs.getString('guest_address') ??
                  '',
            );
      } else {
        // ----------------------------------------------------------
        // Real User
        // ----------------------------------------------------------

        _nameController =
            TextEditingController(
              text: widget.profile.fullName ?? '',
            );

        _mobileController =
            TextEditingController(
              text: widget.profile.mobile ?? '',
            );

        _emailController =
            TextEditingController(
              text: widget.profile.email ?? '',
            );

        _dobController =
            TextEditingController(
              text: _formatDob(widget.profile.dob),
            );

        _addressController =
            TextEditingController(
              text: widget.profile.address ?? '',
            );

        _uploadedPhotoUrl =
            widget.profile.photoUrl;
      }
    });
  }

  // ===========================================================================
  // DOB FORMAT
  // ===========================================================================

  String _formatDob(String? dob) {
    if (dob == null || dob.trim().isEmpty) {
      return '';
    }

    final value = dob.trim();

    try {
      final date = DateTime.parse(value);

      return '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // IMAGE PICK + PROVIDER UPLOAD
  // ===========================================================================

  Future<void> _pickAndUploadImage(
      ImageSource source,
      ) async {
    if (_isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in to upload a profile picture.',
          ),
        ),
      );

      return;
    }

    final picker = ImagePicker();

    final pickedFile =
    await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (pickedFile == null) {
      return;
    }

    final imageFile =
    File(pickedFile.path);

    final provider =
    context.read<UserProvider>();

    setState(() {
      _selectedImage = imageFile;
    });

    final result =
    await provider.uploadProfilePicture(
      imageFile,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final photoUrl =
      result['profilePic']?.toString();

      setState(() {
        if (photoUrl != null &&
            photoUrl.isNotEmpty) {
          _uploadedPhotoUrl = photoUrl;
        } else {
          _uploadedPhotoUrl =
              provider.uploadedPhotoUrl;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile picture updated!',
          ),
        ),
      );
    } else {
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'Failed to upload profile picture.',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // DATE PICKER
  // ===========================================================================

  Future<void> _selectDate() async {
    DateTime initial =
    DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );

    if (_dobController.text.trim().isNotEmpty) {
      try {
        initial =
            DateTime.parse(
              _dobController.text.trim(),
            );
      } catch (_) {}
    }

    final DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _dobController.text =
      '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  // ===========================================================================
  // SAVE PROFILE
  // ===========================================================================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ======================================================================
      // GUEST
      // ======================================================================

      if (_isGuest) {
        final prefs =
        await SharedPreferences.getInstance();

        await prefs.setString(
          'guest_name',
          _nameController.text.trim(),
        );

        await prefs.setString(
          'guest_phone',
          _mobileController.text.trim(),
        );

        await prefs.setString(
          'guest_email',
          _emailController.text.trim(),
        );

        await prefs.setString(
          'guest_dob',
          _dobController.text.trim(),
        );

        await prefs.setString(
          'guest_address',
          _addressController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Guest profile updated!',
            ),
          ),
        );

        Navigator.pop(context, true);

        return;
      }

      // ======================================================================
      // REAL USER — PROVIDER
      // ======================================================================

      final provider =
      context.read<UserProvider>();

      // Provider already handles:
      // - DOB conversion
      // - API request
      // - token
      // - error handling
      // - profile refresh

      provider.nameController.text =
          _nameController.text.trim();

      provider.phoneController.text =
          _mobileController.text.trim();

      provider.emailController.text =
          _emailController.text.trim();

      provider.dobController.text =
          _dobController.text.trim();

      provider.addressController.text =
          _addressController.text.trim();

      final result =
      await provider.saveUserDetails();

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated successfully!',
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Failed to update profile.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ===========================================================================
  // IMAGE PICKER MODAL
  // ===========================================================================

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                ),
                title: const Text(
                  'Choose from Gallery',
                ),
                onTap: () {
                  Navigator.pop(context);

                  _pickAndUploadImage(
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                ),
                title: const Text(
                  'Take a Photo',
                ),
                onTap: () {
                  Navigator.pop(context);

                  _pickAndUploadImage(
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final bg = dark
        ? const Color(0xFF0A0F1C)
        : const Color(0xFFF2F4F8);

    final surface = dark
        ? const Color(0xFF111827)
        : Colors.white;

    final text = dark
        ? Colors.white
        : const Color(0xFF0B1628);

    final userProvider =
    context.watch<UserProvider>();

    final isUploadingImage =
        userProvider.isUploadingImage;

    final photoUrl =
        userProvider.uploadedPhotoUrl ??
            _uploadedPhotoUrl;

    return Scaffold(
      backgroundColor: bg,

      // ========================================================================
      // APP BAR
      // ========================================================================

      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: text,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              true,
            );
          },
        ),

        title: Text(
          _isGuest
              ? 'Edit Guest Profile'
              : 'Edit Profile',
          style: TextStyle(
            color: text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================================
      // BODY
      // ========================================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // ==================================================================
              // AVATAR
              // ==================================================================

              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,

                      backgroundColor:
                      const Color(0xFFC9A227),

                      child: CircleAvatar(
                        radius: 47,

                        backgroundImage:
                        _selectedImage != null
                            ? FileImage(
                          _selectedImage!,
                        )
                            : (photoUrl != null &&
                            photoUrl
                                .isNotEmpty
                            ? CachedNetworkImageProvider(
                          photoUrl,
                        )
                            : null),

                        child:
                        (_selectedImage ==
                            null &&
                            (photoUrl ==
                                null ||
                                photoUrl
                                    .isEmpty))
                            ? Text(
                          widget.profile.initials,
                          style:
                          const TextStyle(
                            fontSize: 32,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            Colors.white,
                          ),
                        )
                            : null,
                      ),
                    ),

                    // ============================================================
                    // UPLOAD LOADER
                    // ============================================================

                    if (isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration:
                          const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),

                          child:
                          const Center(
                            child:
                            CircularProgressIndicator(
                              color:
                              Color(0xFFC9A227),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),

                    // ============================================================
                    // CAMERA BUTTON
                    // ============================================================

                    Positioned(
                      bottom: 0,
                      right: 0,

                      child: GestureDetector(
                        onTap:
                        isUploadingImage
                            ? null
                            : _showImagePickerModal,

                        child: Container(
                          padding:
                          const EdgeInsets.all(8),

                          decoration:
                          const BoxDecoration(
                            color:
                            Color(0xFFC9A227),
                            shape:
                            BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons
                                .camera_alt_rounded,
                            color:
                            Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================================
              // FULL NAME
              // ==================================================================

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_rounded,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================================
              // PHONE
              // ==================================================================

              _buildTextField(
                controller: _mobileController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType:
                TextInputType.phone,
                readOnly: !_isGuest,
                validator: (value) {
                  if (_isGuest &&
                      (value == null ||
                          value
                              .trim()
                              .length <
                              10)) {
                    return 'Enter valid phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================================
              // EMAIL
              // ==================================================================

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_rounded,
                keyboardType:
                TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // ==================================================================
              // DOB
              // ==================================================================

              _buildTextField(
                controller: _dobController,
                label:
                'Date of Birth (YYYY-MM-DD)',
                icon: Icons.cake_rounded,
                readOnly: true,
                onTap: _selectDate,
              ),

              const SizedBox(height: 16),

              // ==================================================================
              // ADDRESS
              // ==================================================================

              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.home_rounded,
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              // ==================================================================
              // SAVE BUTTON
              // ==================================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFC9A227),

                    disabledBackgroundColor:
                    const Color(0xFFC9A227)
                        .withOpacity(0.5),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  onPressed:
                  (_isSaving ||
                      isUploadingImage)
                      ? null
                      : _saveProfile,

                  child: _isSaving
                      ? const SizedBox(
                    height: 24,
                    width: 24,

                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save Changes',

                    style:
                    TextStyle(
                      color:
                      Colors.white,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
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

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    final dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final surface = dark
        ? const Color(0xFF111827)
        : Colors.white;

    return TextFormField(
      controller: controller,

      readOnly: readOnly,

      maxLines: maxLines,

      onTap: onTap,

      keyboardType: keyboardType,

      validator: validator,

      style: TextStyle(
        color: readOnly
            ? Colors.grey
            : (dark
            ? Colors.white
            : Colors.black),
      ),

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(
          icon,
          color:
          const Color(0xFFC9A227),
        ),

        filled: true,

        fillColor: surface,

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          BorderSide.none,
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          BorderSide.none,
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          const BorderSide(
            color:
            Color(0xFFC9A227),
            width: 1.5,
          ),
        ),

        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),

          borderSide:
          const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}