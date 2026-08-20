// ─────────────────────────────────────────────────────────────────────────────
// USER MODEL (Updated with Extended Fields & Guest Support)
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String mobile;
  final String? photoUrl;
  final String dob;
  final String address;
  final String memberSince;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.photoUrl,
    this.dob = '',
    this.address = '',
    this.memberSince = '',
  });

  // Factory Constructor (API & JSON Parsing)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] as int?,
      fullName: json["fullName"]?.toString() ?? json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      mobile: json["mobile"]?.toString() ?? json["phone"]?.toString() ?? "",
      photoUrl: json["profilePic"]?.toString() ?? json["photoUrl"]?.toString(),
      dob: json["dob"]?.toString() ?? "",
      address: json["address"]?.toString() ?? "",
      memberSince: json["memberSince"]?.toString() ?? "",
    );
  }

  // To JSON Map Conversion
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'profilePic': photoUrl,
      'dob': dob,
      'address': address,
      'memberSince': memberSince,
    };
  }


  String get initials {
    if (fullName.trim().isEmpty) return "G";

    final parts = fullName.trim().split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      return "${parts.first[0]}${parts.last[0]}".toUpperCase();
    }

    return parts.first[0].toUpperCase();
  }

  // Guest Default Fallback
  factory UserModel.guest() {
    return UserModel(
      id: null,
      fullName: "Guest User",
      email: "",
      mobile: "Guest Session",
      photoUrl: null,
      dob: "",
      address: "",
      memberSince: "",
    );
  }
}