import 'package:flutter/material.dart';
import 'package:loanready_app/presentation/screens/register/upload_documents_screen.dart';
import 'package:loanready_app/presentation/screens/splash/splash_screen.dart';
import 'package:loanready_app/presentation/screens/home/home_screen.dart';

import '../presentation/aboutus/aboutus_screen.dart';
import '../presentation/screens/auth/OtpLoginScreen.dart';
import '../presentation/screens/auth/VerifyOtpScreen.dart';
import '../presentation/screens/payment/confirm_payment_screen.dart';
import '../presentation/screens/plan/choose_plan_screen.dart';
import '../presentation/screens/register/business_details_screen.dart';
import '../presentation/screens/register/register_screen.dart';
import '../presentation/screens/register/upload_photo_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String about = '/about';
  static const String register = '/register';
  static const String businessDetails = '/businessDetails';
  static const String uploadDocuments = '/uploadDocuments';
  static const String uploadPhoto = '/uploadPhoto';
  static const String choosePlan = '/choosePlan';
  static const String confirmPayment = '/confirmPayment';
  static const otpLogin = '/otpLogin';
  static const verifyOtp = '/verifyOtp';




  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    about: (context) => const AboutUsScreen(),
    register: (context) => const RegisterScreen(),
    businessDetails: (context) => const BusinessDetailsScreen(),
    uploadDocuments: (context) => const UploadDocumentsScreen(),
    uploadPhoto: (context) => const UploadPhotoScreen(),
    choosePlan: (context) => const ChoosePlanScreen(),
    confirmPayment: (context) => const ConfirmPaymentScreen(),
    // AppRoutes.otpLogin: (context) => const OtpLoginScreen(),
    // AppRoutes.verifyOtp: (context) => const VerifyOtpScreen(mobile: '9876543210', verificationId: '8475jdfb4jb34',),




  };
}
