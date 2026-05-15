import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loanready_app/presentation/screens/register/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:loanready_app/routes/app_routes.dart';
import 'firebase_options.dart';

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