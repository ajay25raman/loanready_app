import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loanready_app/payments/payment_screen.dart';
import 'package:loanready_app/presentation/screens/register/profile_screen.dart';
import 'package:loanready_app/providers/auth_provider.dart';
import 'package:loanready_app/providers/business_provider.dart';
import 'package:loanready_app/providers/document_provider.dart';
import 'package:loanready_app/providers/one_year_report_provider.dart';
import 'package:loanready_app/providers/theme_provider.dart';
import 'package:loanready_app/providers/upload_photo_provider.dart';
import 'package:loanready_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:loanready_app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'providers/one_year_trading_provider.dart';

// ThemeProvider import karo
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) => OneYearReportProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => BusinessProvider(),
        ),

        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => OneYearTradingProvider()),
        ChangeNotifierProvider(create: (_) => UploadPhotoProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const LoanReadyApp(),
    ),
  );
}

class LoanReadyApp extends StatelessWidget {
  const LoanReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
     // home: PaymentScreen(),
      title: 'Loan Ready App',
      debugShowCheckedModeBanner: false,

      themeMode: themeProvider.themeMode,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
      ),

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}