class DocumentsModel {
  final int? id;

  final String panNumber;
  final String aadhaarNumber;

  final String? panDoc;
  final String? aadhaarDoc;
  final String? shopLicenseDoc;
  final String? gstCertificateDoc;
  final String? businessProofDoc;

  DocumentsModel({
    this.id,
    required this.panNumber,
    required this.aadhaarNumber,
    this.panDoc,
    this.aadhaarDoc,
    this.shopLicenseDoc,
    this.gstCertificateDoc,
    this.businessProofDoc,
  });

  // ==========================================================
  // FROM API RESPONSE
  // ==========================================================

  factory DocumentsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return DocumentsModel(
      id: int.tryParse(
        json['id']?.toString() ?? '',
      ),

      panNumber:
      json['pan_number']?.toString() ?? '',

      aadhaarNumber:
      json['aadhaar_number']?.toString() ?? '',

      panDoc:
      _nullableString(json['pan_doc_url']),

      aadhaarDoc:
      _nullableString(json['aadhaar_doc_url']),

      shopLicenseDoc:
      _nullableString(json['shop_license_url']),

      gstCertificateDoc:
      _nullableString(
        json['gst_certificate_url'],
      ),

      businessProofDoc:
      _nullableString(
        json['business_proof_url'],
      ),
    );
  }

  // ==========================================================
  // TO API REQUEST
  // ==========================================================

  Map<String, dynamic> toJson() {
    return {
      'pan_number': panNumber,
      'aadhaar_number': aadhaarNumber,

      if (panDoc != null && panDoc!.isNotEmpty)
        'pan_doc_url': panDoc,

      if (aadhaarDoc != null &&
          aadhaarDoc!.isNotEmpty)
        'aadhaar_doc_url': aadhaarDoc,

      if (shopLicenseDoc != null &&
          shopLicenseDoc!.isNotEmpty)
        'shop_license_url': shopLicenseDoc,

      if (gstCertificateDoc != null &&
          gstCertificateDoc!.isNotEmpty)
        'gst_certificate_url':
        gstCertificateDoc,

      if (businessProofDoc != null &&
          businessProofDoc!.isNotEmpty)
        'business_proof_url':
        businessProofDoc,
    };
  }

  // ==========================================================
  // EMPTY MODEL
  // ==========================================================

  factory DocumentsModel.empty() {
    return DocumentsModel(
      id: null,
      panNumber: '',
      aadhaarNumber: '',
      panDoc: null,
      aadhaarDoc: null,
      shopLicenseDoc: null,
      gstCertificateDoc: null,
      businessProofDoc: null,
    );
  }

  // ==========================================================
  // NULLABLE STRING HELPER
  // ==========================================================

  static String? _nullableString(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty ||
        text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}