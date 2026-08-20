import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:loanready_app/Model/document_model.dart';
import 'package:loanready_app/services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _apiService = DocumentService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController panController =
  TextEditingController();

  final TextEditingController aadhaarController =
  TextEditingController();

  // ============================================================
  // Local File Names
  // ============================================================

  String? panFileName;
  String? aadhaarFileName;
  String? shopLicenseName;
  String? gstCertificateName;
  String? businessProofName;

  // ============================================================
  // Local File Paths
  // ============================================================

  String? panFilePath;
  String? aadhaarFilePath;
  String? shopLicensePath;
  String? gstCertificatePath;
  String? businessProofPath;

  // ============================================================
  // SERVER DOCUMENT URLS
  // ============================================================

  String? panDocUrl;
  String? aadhaarDocUrl;
  String? shopLicenseUrl;
  String? gstCertificateUrl;
  String? businessProofUrl;
  String? photoUrl;

  // ============================================================
  // DOCUMENT ID
  // ============================================================

  int? documentId;


  bool get isPanUploaded =>
      _hasValue(panDocUrl) ||
          _hasValue(panFilePath);

  bool get isAadhaarUploaded =>
      _hasValue(aadhaarDocUrl) ||
          _hasValue(aadhaarFilePath);

  bool get isShopLicenseUploaded =>
      _hasValue(shopLicenseUrl) ||
          _hasValue(shopLicensePath);

  bool get isGstCertificateUploaded =>
      _hasValue(gstCertificateUrl) ||
          _hasValue(gstCertificatePath);

  bool get isBusinessProofUploaded =>
      _hasValue(businessProofUrl) ||
          _hasValue(businessProofPath);
  // ============================================================
  // FORM VALIDATION
  // ============================================================

  bool get isFormValid {
    final panAvailable =
        panFilePath != null ||
            _hasValue(panDocUrl);

    final aadhaarAvailable =
        aadhaarFilePath != null ||
            _hasValue(aadhaarDocUrl);

    return panController.text
        .trim()
        .isNotEmpty &&
        aadhaarController.text
            .trim()
            .isNotEmpty &&
        panAvailable &&
        aadhaarAvailable;
  }

  // ============================================================
  // SERVER DOCUMENT STATUS
  // ============================================================



  bool _hasValue(String? value) {
    return value != null &&
        value.trim().isNotEmpty;
  }

  // ============================================================
  // FULL DOCUMENT URL
  // ============================================================

  String? getFullDocumentUrl(
      String? path,
      ) {
    if (!_hasValue(path)) {
      return null;
    }

    // Already complete URL
    if (path!.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    return 'https://loan.edugaondev.com$path';
  }

  // ============================================================
  // FILE PICKER + OCR
  // ============================================================

  Future<void> pickAndProcessFile({
    required Function(
        String path,
        String name,
        ) onPicked,
    bool isPan = false,
    bool isAadhaar = false,
  }) async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'png',
          'jpg',
          'jpeg',
          'pdf',
        ],
      );

      if (result == null ||
          result.files.single.path == null) {
        return;
      }

      final filePath =
      result.files.single.path!;

      final fileName =
          result.files.single.name;

      // Update local file
      onPicked(
        filePath,
        fileName,
      );

      notifyListeners();

      // ========================================================
      // OCR ONLY FOR IMAGES
      // ========================================================

      final lowerPath =
      filePath.toLowerCase();

      final isImage =
          lowerPath.endsWith('.png') ||
              lowerPath.endsWith('.jpg') ||
              lowerPath.endsWith('.jpeg');

      if (!isImage) {
        return;
      }

      final extractedText =
      await _apiService
          .extractTextFromImage(
        filePath,
      );

      if (extractedText == null ||
          extractedText.trim().isEmpty) {
        return;
      }

      // ========================================================
      // PAN OCR
      // ========================================================

      if (isPan) {
        final panRegex = RegExp(
          r'\b[A-Z]{5}[0-9]{4}[A-Z]\b',
        );

        final match =
        panRegex.firstMatch(
          extractedText.toUpperCase(),
        );

        if (match != null) {
          panController.text =
          match.group(0)!;

          notifyListeners();
        }
      }

      // ========================================================
      // AADHAAR OCR
      // ========================================================

      if (isAadhaar) {
        final aadhaarRegex = RegExp(
          r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
        );

        final match =
        aadhaarRegex.firstMatch(
          extractedText,
        );

        if (match != null) {
          aadhaarController.text =
              match
                  .group(0)!
                  .replaceAll(
                RegExp(r'[\s-]'),
                '',
              );

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint(
        'FILE PICKER ERROR => $e',
      );
    }
  }

  // ============================================================
  // GET DOCUMENTS FROM SERVER
  // ============================================================

  Future<Map<String, dynamic>>
  fetchDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result =
      await _apiService.getDocuments();

      if (result['success'] == true) {
        final documents =
        result['documents'];

        if (documents is Map) {
          documentId =
              _toInt(documents['id']);

          // ----------------------------------------------------
          // Numbers
          // ----------------------------------------------------

          final panNumber =
          documents['pan_number'];

          if (panNumber != null &&
              panNumber
                  .toString()
                  .trim()
                  .isNotEmpty) {
            panController.text =
                panNumber.toString();
          }

          final aadhaarNumber =
          documents['aadhaar_number'];

          if (aadhaarNumber != null &&
              aadhaarNumber
                  .toString()
                  .trim()
                  .isNotEmpty) {
            aadhaarController.text =
                aadhaarNumber.toString();
          }

          // ----------------------------------------------------
          // Server URLs
          // ----------------------------------------------------

          panDocUrl =
              documents['pan_doc_url']
                  ?.toString();

          aadhaarDocUrl =
              documents[
              'aadhaar_doc_url']
                  ?.toString();

          shopLicenseUrl =
              documents[
              'shop_license_url']
                  ?.toString();

          gstCertificateUrl =
              documents[
              'gst_certificate_url']
                  ?.toString();

          businessProofUrl =
              documents[
              'business_proof_url']
                  ?.toString();

          photoUrl =
              documents['photo_url']
                  ?.toString();

          debugPrint(
            'PAN URL => $panDocUrl',
          );

          debugPrint(
            'AADHAAR URL => '
                '$aadhaarDocUrl',
          );

          debugPrint(
            'SHOP LICENSE URL => '
                '$shopLicenseUrl',
          );

          debugPrint(
            'GST URL => '
                '$gstCertificateUrl',
          );

          debugPrint(
            'BUSINESS PROOF URL => '
                '$businessProofUrl',
          );
        }

        notifyListeners();
      }

      return result;
    } catch (e) {
      debugPrint(
        'FETCH DOCUMENTS ERROR => $e',
      );

      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SAVE / CREATE DOCUMENTS
  // ============================================================

  Future<Map<String, dynamic>>
  saveDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final docs = DocumentsModel(
        panNumber:
        panController.text.trim(),

        aadhaarNumber:
        aadhaarController.text.trim(),

        panDoc:
        panFilePath,

        aadhaarDoc:
        aadhaarFilePath,

        shopLicenseDoc:
        shopLicensePath,

        gstCertificateDoc:
        gstCertificatePath,

        businessProofDoc:
        businessProofPath,
      );

      final result =
      await _apiService
          .uploadDocuments(docs);

      // ========================================================
      // SUCCESS
      // ========================================================

      if (result['success'] == true) {
        final documents =
        result['documents'];

        if (documents is Map) {
          documentId =
              _toInt(documents['id']);

          panDocUrl =
              documents['pan_doc_url']
                  ?.toString();

          aadhaarDocUrl =
              documents[
              'aadhaar_doc_url']
                  ?.toString();

          shopLicenseUrl =
              documents[
              'shop_license_url']
                  ?.toString();

          gstCertificateUrl =
              documents[
              'gst_certificate_url']
                  ?.toString();

          businessProofUrl =
              documents[
              'business_proof_url']
                  ?.toString();

          photoUrl =
              documents['photo_url']
                  ?.toString();
        }

        notifyListeners();
      }

      return result;
    } catch (e) {
      debugPrint(
        'SAVE DOCUMENT ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Failed to save documents: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE DOCUMENTS
  // ============================================================

  Future<Map<String, dynamic>>
  updateDocuments() async {
    if (documentId == null) {
      return {
        'success': false,
        'message':
        'Document ID not found.',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      final docs = DocumentsModel(
        panNumber:
        panController.text.trim(),

        aadhaarNumber:
        aadhaarController.text.trim(),

        panDoc:
        panFilePath,

        aadhaarDoc:
        aadhaarFilePath,

        shopLicenseDoc:
        shopLicensePath,

        gstCertificateDoc:
        gstCertificatePath,

        businessProofDoc:
        businessProofPath,
      );

      final result =
      await _apiService.updateDocuments(
        documentId!,
        docs,
      );

      if (result['success'] == true) {
        await fetchDocuments();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message':
        'Failed to update documents: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DELETE DOCUMENT
  // ============================================================

  Future<Map<String, dynamic>>
  deleteDocuments() async {
    if (documentId == null) {
      return {
        'success': false,
        'message':
        'Document ID not found.',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result =
      await _apiService.deleteDocument(
        documentId!,
      );

      if (result['success'] == true) {
        resetState();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message':
        'Failed to delete documents: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // RESET
  // ============================================================

  void resetState() {
    panController.clear();
    aadhaarController.clear();

    panFileName = null;
    aadhaarFileName = null;
    shopLicenseName = null;
    gstCertificateName = null;
    businessProofName = null;

    panFilePath = null;
    aadhaarFilePath = null;
    shopLicensePath = null;
    gstCertificatePath = null;
    businessProofPath = null;

    panDocUrl = null;
    aadhaarDocUrl = null;
    shopLicenseUrl = null;
    gstCertificateUrl = null;
    businessProofUrl = null;
    photoUrl = null;

    documentId = null;

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  @override
  void dispose() {
    panController.dispose();
    aadhaarController.dispose();

    super.dispose();
  }
}