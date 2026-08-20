class UserProfileModel {
  final String? fullName;
  final String? mobile;
  final String? email;
  final String? dob;
  final String? address;
  final String? photoUrl;
  final int? creditScore;
  final int activeLoans;
  final String? memberSince;

  final String aadhaarStatus;
  final String panStatus;
  final String bankStatus;
  final String addressDocStatus;

  const UserProfileModel({
    this.fullName,
    this.mobile,
    this.email,
    this.dob,
    this.address,
    this.photoUrl,
    this.creditScore,
    this.activeLoans = 0,
    this.memberSince,
    this.aadhaarStatus = 'missing',
    this.panStatus = 'missing',
    this.bankStatus = 'missing',
    this.addressDocStatus = 'missing',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String memberSince = "";
    final createdAt = json["createdAt"]?.toString() ?? "";

    if (createdAt.isNotEmpty) {
      try {
        memberSince = DateTime.parse(createdAt).year.toString();
      } catch (_) {
        memberSince = "";
      }
    }

    final kyc = (json["kyc"] as Map<String, dynamic>?) ?? {};
    final data = (json["data"] as Map<String, dynamic>?) ?? {};

    String parseStatus(List<String> statusKeys, List<String> urlKeys) {
      for (final key in statusKeys) {
        if (kyc.containsKey(key) &&
            kyc[key] != null &&
            kyc[key].toString().isNotEmpty) {
          return kyc[key].toString().toLowerCase();
        }
        if (json.containsKey(key) &&
            json[key] != null &&
            json[key].toString().isNotEmpty) {
          return json[key].toString().toLowerCase();
        }
      }

      for (final urlKey in urlKeys) {
        final val = json[urlKey] ?? data[urlKey] ?? kyc[urlKey];
        if (val != null &&
            val.toString().trim().isNotEmpty &&
            val.toString() != "null") {
          return "pending";
        }
      }

      return "missing";
    }

    return UserProfileModel(
      fullName: json["fullName"]?.toString(),
      mobile: json["mobile"]?.toString(),
      email: json["email"]?.toString(),
      dob: json["dob"]?.toString(),
      address: json["address"]?.toString(),
      photoUrl:
      json["profilePic"]?.toString() ?? json["photoUrl"]?.toString(),
      creditScore: json["creditScore"] is int
          ? json["creditScore"]
          : int.tryParse(json["creditScore"]?.toString() ?? ''),
      activeLoans: json["activeLoans"] ?? 0,
      memberSince: memberSince.isNotEmpty
          ? memberSince
          : json["memberSince"]?.toString(),
      aadhaarStatus: parseStatus(
        ["aadhaar", "aadhaar_status", "aadhaarStatus"],
        ["aadhaarDocUrl", "aadhaarUrl", "aadhaarDoc"],
      ),
      panStatus: parseStatus(
        ["pan", "pan_status", "panStatus"],
        ["panDocUrl", "panUrl", "panDoc"],
      ),
      bankStatus: parseStatus(
        ["bank", "bank_status", "bankStatus"],
        ["bankDocUrl", "bankUrl", "statementUrl"],
      ),
      addressDocStatus: parseStatus(
        ["address", "address_status", "addressStatus"],
        [
          "businessProofUrl",
          "shopLicenseUrl",
          "gstCertificateUrl",
          "addressDocUrl"
        ],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dob': dob,
      'email': email,
      'address': address,
      if (mobile != null && mobile!.isNotEmpty)
        'mobile': '+91${mobile!.replaceAll('+91', '').trim()}',
    };
  }

  // ─── UI Helpers ─────────────────────────────────────────────────────────────
  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : '—';

  String get displayEmail =>
      (email != null && email!.trim().isNotEmpty) ? email! : '—';

  String get displayAddress =>
      (address != null && address!.trim().isNotEmpty) ? address! : '—';

  String get initials {
    if (fullName == null || fullName!.trim().isEmpty) return '?';
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String get formattedMobile {
    if (mobile == null || mobile!.trim().isEmpty) return '—';
    final clean = mobile!.replaceAll('+91', '').trim();
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return mobile!;
  }

  String get formattedDob {
    if (dob == null || dob!.trim().isEmpty) return '—';
    try {
      final d = DateTime.parse(dob!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return dob!;
    }
  }

  bool get isKycComplete =>
      (aadhaarStatus == 'verified' || aadhaarStatus == 'pending') &&
          (panStatus == 'verified' || panStatus == 'pending') &&
          (bankStatus == 'verified' || bankStatus == 'pending') &&
          (addressDocStatus == 'verified' || addressDocStatus == 'pending');
}