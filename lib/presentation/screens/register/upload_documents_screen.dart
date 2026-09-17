import 'package:flutter/material.dart';
import 'package:loanready_app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:loanready_app/providers/document_provider.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() =>
      _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState
    extends State<UploadDocumentsScreen> {
  final _formKey = GlobalKey<FormState>();

  // =============================================================
  // VALIDATION
  // =============================================================

  String? _validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }

    final pan = value.trim().toUpperCase();

    if (!RegExp(
      r'^[A-Z]{5}[0-9]{4}[A-Z]$',
    ).hasMatch(pan)) {
      return 'Enter a valid 10-character PAN';
    }

    return null;
  }

  String? _validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }

    final aadhaar =
    value.replaceAll(RegExp(r'[\s-]'), '');

    if (!RegExp(
      r'^[0-9]{12}$',
    ).hasMatch(aadhaar)) {
      return 'Enter a valid 12-digit Aadhaar number';
    }

    return null;
  }

  // =============================================================
  // SNACKBAR
  // =============================================================

  void _showSnackBar(
      BuildContext context,
      String message,
      bool isSuccess,
      ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(
            milliseconds: 900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // =============================================================
  // INIT
  // =============================================================

  @override
  void initState() {
    super.initState();

    // Fetch existing uploaded documents only once.
    // This is required so previously uploaded documents
    // show as "Uploaded" when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<DocumentProvider>()
          .fetchDocuments();
    });
  }

  // =============================================================
  // SUBMIT DOCUMENTS
  // =============================================================

  Future<void> _submitDocuments(
      BuildContext context,
      DocumentProvider provider,
      ) async {
    if (provider.isLoading) return;

    FocusScope.of(context).unfocus();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // REQUIRED DOCUMENTS
    // ----------------------------------------------------------

    if (!provider.isPanUploaded) {
      _showSnackBar(
        context,
        'Please upload PAN Card.',
        false,
      );
      return;
    }

    if (!provider.isAadhaarUploaded) {
      _showSnackBar(
        context,
        'Please upload Aadhaar Card.',
        false,
      );
      return;
    }

    // ----------------------------------------------------------
    // ONE CREATE API CALL
    // ----------------------------------------------------------

    final result = await provider.saveDocuments();

    if (!context.mounted) return;

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------

    if (result['success'] == true) {
      _showSnackBar(
        context,
        result['message']?.toString() ??
            'Documents submitted successfully!',
        true,
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (route) => false,
      );

      return;
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    _showSnackBar(
      context,
      result['message']?.toString() ??
          'Failed to save documents.',
      false,
    );
  }
  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<DocumentProvider>();

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F9FC),

      // =========================================================
      // APP BAR
      // =========================================================

      appBar: AppBar(
        title: const Text(
          'Upload KYC & Business Docs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor:
        const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // =========================================================
      // BODY
      // =========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            24,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode:
            AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                // =================================================
                // LOADING
                // =================================================

                if (provider.isLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                  ),

                // =================================================
                // PROGRESS
                // =================================================

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF1E293B,
                        ).withAlpha(13),
                        blurRadius: 20,
                        offset:
                        const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child:
                          const LinearProgressIndicator(
                            value: 1.0,
                            minHeight: 8,
                            backgroundColor:
                            Color(0xFFE5E7EB),
                            color:
                            Color(0xFFC9A227),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

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
                          'Step 3/3',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            fontSize: 13,
                            color:
                            Color(0xFFC9A227),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // PAN
                // =================================================

                _buildSectionHeader(
                  '1. PAN Card Verification',
                ),

                const SizedBox(height: 12),

                _buildDocTile(
                  title:
                  'Upload PAN Card Image*',
                  subtitle:
                  provider.isPanUploaded
                      ? (provider.panFileName ??
                      'PAN document already uploaded')
                      : 'PNG, JPG allowed (OCR auto-detects number)',
                  isUploaded:
                  provider.isPanUploaded,
                  onTap: () {
                    provider.pickAndProcessFile(
                      isPan: true,
                      onPicked:
                          (path, name) {
                        provider.panFilePath =
                            path;
                        provider.panFileName =
                            name;
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller:
                  provider.panController,
                  validator: _validatePan,
                  textCapitalization:
                  TextCapitalization.characters,
                  decoration:
                  _inputDecoration(
                    label:
                    'PAN Number*',
                    hint:
                    'ABCDE1234F',
                    icon:
                    Icons.credit_card_rounded,
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // AADHAAR
                // =================================================

                _buildSectionHeader(
                  '2. Aadhaar Card Verification',
                ),

                const SizedBox(height: 12),

                _buildDocTile(
                  title:
                  'Upload Aadhaar Card Image*',
                  subtitle:
                  provider.isAadhaarUploaded
                      ? (provider.aadhaarFileName ??
                      'Aadhaar document already uploaded')
                      : 'PNG, JPG allowed (OCR auto-detects number)',
                  isUploaded:
                  provider.isAadhaarUploaded,
                  onTap: () {
                    provider.pickAndProcessFile(
                      isAadhaar: true,
                      onPicked:
                          (path, name) {
                        provider.aadhaarFilePath =
                            path;
                        provider.aadhaarFileName =
                            name;
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller:
                  provider.aadhaarController,
                  validator:
                  _validateAadhaar,
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  _inputDecoration(
                    label:
                    'Aadhaar Number*',
                    hint:
                    '12-digit number',
                    icon: Icons
                        .fingerprint_rounded,
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // BUSINESS DOCUMENTS
                // =================================================

                _buildSectionHeader(
                  '3. Business Proofs (Optional)',
                ),

                const SizedBox(height: 12),

                // -------------------------------------------------
                // SHOP LICENSE
                // -------------------------------------------------

                _buildDocTile(
                  title:
                  'Shop License',
                  subtitle:
                  provider.isShopLicenseUploaded
                      ? (provider.shopLicenseName ??
                      'Shop License already uploaded')
                      : 'Upload Shop / Establishment License',
                  isUploaded:
                  provider
                      .isShopLicenseUploaded,
                  onTap: () {
                    provider.pickAndProcessFile(
                      onPicked:
                          (path, name) {
                        provider.shopLicensePath =
                            path;
                        provider.shopLicenseName =
                            name;
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // GST
                // -------------------------------------------------

                _buildDocTile(
                  title:
                  'GST Certificate',
                  subtitle:
                  provider.isGstCertificateUploaded
                      ? (provider.gstCertificateName ??
                      'GST Certificate already uploaded')
                      : 'Upload GST Registration Certificate',
                  isUploaded:
                  provider
                      .isGstCertificateUploaded,
                  onTap: () {
                    provider.pickAndProcessFile(
                      onPicked:
                          (path, name) {
                        provider
                            .gstCertificatePath =
                            path;
                        provider
                            .gstCertificateName =
                            name;
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------
                // BUSINESS PROOF
                // -------------------------------------------------

                _buildDocTile(
                  title:
                  'Other Business Proof',
                  subtitle:
                  provider.isBusinessProofUploaded
                      ? (provider.businessProofName ??
                      'Business proof already uploaded')
                      : 'Utility Bill / Rent Agreement',
                  isUploaded:
                  provider
                      .isBusinessProofUploaded,
                  onTap: () {
                    provider.pickAndProcessFile(
                      onPicked:
                          (path, name) {
                        provider
                            .businessProofPath =
                            path;
                        provider
                            .businessProofName =
                            name;
                      },
                    );
                  },
                ),

                const SizedBox(height: 36),

                // =================================================
                // SUBMIT BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _submitDocuments(
                      context,
                      provider,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      const Color(0xFFC9A227).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Submit Documents',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SECTION HEADER
  // =============================================================

  Widget _buildSectionHeader(
      String title,
      ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  // =============================================================
  // DOCUMENT TILE
  // =============================================================

  Widget _buildDocTile({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: Container(
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded
              ? const Color(0xFFF0FDF4)
              : Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded
                ? Colors.green.shade300
                : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:
              const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.shade100
                    : const Color(
                  0xFFC9A227,
                ).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded
                    ? Icons
                    .check_circle_rounded
                    : Icons
                    .cloud_upload_outlined,
                color: isUploaded
                    ? Colors.green.shade700
                    : const Color(
                  0xFFC9A227,
                ),
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploaded
                          ? Colors
                          .green.shade800
                          : Colors
                          .grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    isUploaded
                        ? 'Uploaded'
                        : 'Missing',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w700,
                      color: isUploaded
                          ? Colors
                          .green.shade700
                          : Colors
                          .red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              isUploaded
                  ? Icons.edit_rounded
                  : Icons
                  .chevron_right_rounded,
              color: isUploaded
                  ? Colors.green.shade700
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // INPUT DECORATION
  // =============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color:
        const Color(0xFFC9A227),
        size: 20,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),

      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        BorderSide.none,
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color:
          Color(0xFFC9A227),
          width: 2,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color:
          Colors.redAccent,
          width: 1.2,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide:
        const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}