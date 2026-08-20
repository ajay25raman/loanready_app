import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:loanready_app/providers/document_provider.dart';

class DocumentEditScreen extends StatefulWidget {
  final String documentType;

  const DocumentEditScreen({
    super.key,
    required this.documentType,
  });

  @override
  State<DocumentEditScreen> createState() =>
      _DocumentEditScreenState();
}

class _DocumentEditScreenState
    extends State<DocumentEditScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isPicking = false;

  String? _selectedFilePath;
  String? _existingUrl;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingDocument();
    });
  }

  void _loadExistingDocument() {
    final provider =
    context.read<DocumentProvider>();

    switch (widget.documentType) {
      case 'PAN Card':
        _existingUrl = provider.panDocUrl;
        break;

      case 'Aadhaar Card':
        _existingUrl = provider.aadhaarDocUrl;
        break;

      case 'Shop License':
        _existingUrl = provider.shopLicenseUrl;
        break;

      case 'GST Certificate':
        _existingUrl = provider.gstCertificateUrl;
        break;

      case 'Business Proof':
        _existingUrl = provider.businessProofUrl;
        break;
    }

    setState(() {});
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final XFile? picked =
      await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _selectedFilePath = picked.path;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to select image',
        false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final XFile? picked =
      await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _selectedFilePath = picked.path;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to capture image',
        false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage();
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
                    Navigator.pop(sheetContext);
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveDocument() async {
    if (_selectedFilePath == null) {
      _showMessage(
        'Please select a new document image.',
        false,
      );
      return;
    }

    final provider =
    context.read<DocumentProvider>();

    /*
     * Update selected local file according to document type.
     */
    switch (widget.documentType) {
      case 'PAN Card':
        provider.panFilePath =
            _selectedFilePath;
        break;

      case 'Aadhaar Card':
        provider.aadhaarFilePath =
            _selectedFilePath;
        break;

      case 'Shop License':
        provider.shopLicensePath =
            _selectedFilePath;
        break;

      case 'GST Certificate':
        provider.gstCertificatePath =
            _selectedFilePath;
        break;

      case 'Business Proof':
        provider.businessProofPath =
            _selectedFilePath;
        break;
    }

    final result =
    await provider.saveDocuments();

    if (!mounted) return;

    if (result['success'] == true) {
      await provider.fetchDocuments();

      if (!mounted) return;

      _showMessage(
        'Document updated successfully',
        true,
      );

      Navigator.pop(context, true);
    } else {
      _showMessage(
        result['message']?.toString() ??
            'Failed to update document',
        false,
      );
    }
  }

  void _showMessage(
      String message,
      bool success,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<DocumentProvider>();

    final isUploaded =
        _existingUrl != null &&
            _existingUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit ${widget.documentType}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // =================================================
            // STATUS
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color: isUploaded
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUploaded
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: isUploaded
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isUploaded
                          ? 'Document is already uploaded'
                          : 'Document is not uploaded',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w600,
                        color: isUploaded
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Current Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            // =================================================
            // CURRENT IMAGE
            // =================================================

            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(18),
                child: _buildPreview(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Replace Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: _isPicking
                  ? null
                  : _showPicker,
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(
                      0xFFC9A227,
                    ),
                    width: 1.2,
                  ),
                ),
                child: _isPicking
                    ? const Center(
                  child:
                  CircularProgressIndicator(
                    color:
                    Color(0xFFC9A227),
                  ),
                )
                    : Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons
                          .cloud_upload_rounded,
                      size: 36,
                      color:
                      Color(0xFFC9A227),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to upload new document',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JPG, JPEG or PNG',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedFilePath != null) ...[
              const SizedBox(height: 12),

              Container(
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        File(
                          _selectedFilePath!,
                        ).path.split('/').last,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // =================================================
            // SAVE
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                provider.isLoading ||
                    _selectedFilePath == null
                    ? null
                    : _saveDocument,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFC9A227),
                  disabledBackgroundColor:
                  Colors.grey.shade300,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Update Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedFilePath != null) {
      return Image.file(
        File(_selectedFilePath!),
        fit: BoxFit.cover,
      );
    }

    if (_existingUrl != null &&
        _existingUrl!.trim().isNotEmpty) {
      return Image.network(
        _existingUrl!,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.description_rounded,
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            'No document uploaded',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}