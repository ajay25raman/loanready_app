// ─────────────────────────────────────────────────────────────────────────────
// AUTH & OTP MODELS
// ─────────────────────────────────────────────────────────────────────────────

// 1. Send OTP Request Payload Model
class SendOtpRequestModel {
  final String countryCode;
  final String mobile;
  final String templateId;

  SendOtpRequestModel({
    this.countryCode = "+91",
    required this.mobile,
    this.templateId = "register",
  });

  Map<String, dynamic> toJson() {
    return {
      "countryCode": countryCode,
      "mobile": mobile,
      "templateId": templateId,
    };
  }
}

// 2. Auth / OTP Response Model (Handles OTP Send & Guest Login Responses)
class AuthResponseModel {
  final bool success;
  final String? message;
  final String? verificationId;
  final String? token;
  final Map<String, dynamic>? user;

  AuthResponseModel({
    required this.success,
    this.message,
    this.verificationId,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json, int statusCode) {
    return AuthResponseModel(
      success: json["success"] as bool? ?? (statusCode == 200 || statusCode == 201),
      message: json["message"]?.toString(),
      verificationId: json["verificationId"]?.toString(),
      token: json["token"]?.toString(),
      user: json["user"] is Map<String, dynamic> ? json["user"] as Map<String, dynamic> : null,
    );
  }
}