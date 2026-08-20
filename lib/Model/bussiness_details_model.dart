// ─────────────────────────────────────────────────────────────────────────────
// BUSINESS DETAILS MODEL (Screen UI & API Payload Compliant)
// ─────────────────────────────────────────────────────────────────────────────

class BusinessDetailsModel {
  final int? id;
  final String businessName;
  final String? businessType;
  final double turnover;
  final double cost;
  final String businessAddress;

  BusinessDetailsModel({
    this.id,
    required this.businessName,
    this.businessType,
    required this.turnover,
    required this.cost,
    required this.businessAddress,
  });

  // Factory Constructor for API JSON Parsing
  factory BusinessDetailsModel.fromJson(Map<String, dynamic> json) {
    return BusinessDetailsModel(
      id: json["id"] as int?,
      businessName: json["businessName"]?.toString() ?? "",
      businessType: json["businessType"]?.toString(),
      turnover: (json["turnover"] is num)
          ? (json["turnover"] as num).toDouble()
          : (double.tryParse(json["turnover"]?.toString() ?? "") ?? 0.0),
      cost: (json["cost"] is num)
          ? (json["cost"] as num).toDouble()
          : (double.tryParse(json["cost"]?.toString() ?? "") ?? 0.0),
      businessAddress: json["businessAddress"]?.toString() ??
          json["address"]?.toString() ??
          "",
    );
  }

  // Map Conversion for API POST Request Payload
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'businessName': businessName,
      'businessType': businessType,
      'turnover': turnover,
      'cost': cost,
      'businessAddress': businessAddress,
    };
  }

  // Initial Empty State Fallback
  factory BusinessDetailsModel.empty() {
    return BusinessDetailsModel(
      id: null,
      businessName: "",
      businessType: null,
      turnover: 0.0,
      cost: 0.0,
      businessAddress: "",
    );
  }
}