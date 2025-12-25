import 'package:flutter/material.dart';
import 'package:loanready_app/routes/app_routes.dart';

void main() {
  runApp(const LoanReadyApp());
}

class LoanReadyApp extends StatelessWidget {
  const LoanReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Ready App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
