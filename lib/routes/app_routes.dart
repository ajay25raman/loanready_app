import 'package:flutter/material.dart';
import 'package:loanready_app/presentation/screens/register/upload_documents_screen.dart';
import 'package:loanready_app/presentation/screens/splash/splash_screen.dart';

import '../presentation/aboutus/aboutus_screen.dart';
import '../presentation/screens/auth/otp_login_screen.dart';
import '../presentation/screens/home/bottom_navbar.dart';
import '../presentation/screens/payment/confirm_payment_screen.dart';
import '../presentation/screens/plan/choose_plan_screen.dart';
import '../presentation/screens/register/business_details_screen.dart';
import '../presentation/screens/register/personal_details_screen.dart';
import '../presentation/screens/register/upload_photo_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String about = '/about';
  static const String register = '/register';

  static const String personalDetails = '/personalDetails';

  static const String businessDetails = '/businessDetails';
  static const String uploadDocuments = '/uploadDocuments';
  static const String uploadPhoto = '/uploadPhoto';
  static const String choosePlan = '/choosePlan';
  static const String confirmPayment = '/confirmPayment';
  static const String otpLogin = '/otpLogin';
  static const String verifyOtp = '/verifyOtp';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),

    home: (context) => const MainNavigationScreen(),

    about: (context) => const AboutUsScreen(),

    register: (context) => const PersonalDetailsScreen(),

    // Guest profile / personal details
    personalDetails: (context) => const PersonalDetailsScreen(),

    businessDetails: (context) =>
     BusinessDetailsScreen(),

    uploadDocuments: (context) =>
     UploadDocumentsScreen(),

    uploadPhoto: (context) =>
    const UploadPhotoScreen(),

    choosePlan: (context) =>
    const ChoosePlanScreen(),

    confirmPayment: (context) =>
    const ConfirmPaymentScreen(),

    otpLogin: (context) =>
    const OtpLoginScreen(),
  };
}