class AuthModel {
  final String? mobile;
  final String? countryCode;
  final String? otp;
  final String? verificationId;
  final bool success;
  final String? message;
  final String? token;
  final bool isProfileCompleted;

  AuthModel({
    this.mobile,
    this.countryCode,
    this.otp,
    this.verificationId,
    this.success = false,
    this.message,
    this.token,
    this.isProfileCompleted = false,
  });

  factory AuthModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AuthModel(
      mobile: json['mobile']?.toString(),
      countryCode: json['countryCode']?.toString(),
      otp: json['otp']?.toString(),
      verificationId:
      json['verificationId']?.toString(),

      success:
      json['success'] == true ||
          json['status'] == 200,

      message: json['message']?.toString(),

      token: json['token']?.toString(),

      // IMPORTANT
      isProfileCompleted:
      json['isProfileCompleted'] == true ||
          json['is_profile_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'countryCode': countryCode,
      'otp': otp,
      'verificationId': verificationId,
      'success': success,
      'message': message,
      'token': token,
      'isProfileCompleted':
      isProfileCompleted,
    };
  }
}