// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENTS MODEL (Upload Documents Screen & API Payload Compliant)
// ─────────────────────────────────────────────────────────────────────────────

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

  // Factory Constructor for API JSON Parsing
  factory DocumentsModel.fromJson(Map<String, dynamic> json) {
    return DocumentsModel(
      id: json["id"] as int?,
      panNumber: json["panNumber"]?.toString() ?? "",
      aadhaarNumber: json["aadhaarNumber"]?.toString() ?? "",
      panDoc: json["panDoc"]?.toString(),
      aadhaarDoc: json["aadhaarDoc"]?.toString(),
      shopLicenseDoc: json["shopLicenseDoc"]?.toString(),
      gstCertificateDoc: json["gstCertificateDoc"]?.toString(),
      businessProofDoc: json["businessProofDoc"]?.toString(),
    );
  }

  // Map Conversion for API POST Request Payload
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'panNumber': panNumber,
      'aadhaarNumber': aadhaarNumber,
      'panDoc': panDoc,
      'aadhaarDoc': aadhaarDoc,
      'shopLicenseDoc': shopLicenseDoc,
      'gstCertificateDoc': gstCertificateDoc,
      'businessProofDoc': businessProofDoc,
    };
  }

  // Initial Empty State Fallback
  factory DocumentsModel.empty() {
    return DocumentsModel(
      id: null,
      panNumber: "",
      aadhaarNumber: "",
      panDoc: null,
      aadhaarDoc: null,
      shopLicenseDoc: null,
      gstCertificateDoc: null,
      businessProofDoc: null,
    );
  }
}