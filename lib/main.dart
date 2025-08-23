import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:society_manager/screens/auth/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase before running the app
    await Firebase.initializeApp();

    // Add App Check initialization
    await FirebaseAppCheck.instance.activate(
      // webProvider: ReCaptchaV3Provider('your-actual-recaptcha-key'), // Replace with your real key
      androidProvider: AndroidProvider.playIntegrity, // Use playIntegrity for production
      // appleProvider: AppleProvider.appAttest, // For iOS
    );
  } catch (e) {
    // print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocietySphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
