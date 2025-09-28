import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/email_verification_page.dart';
import 'pages/verification_complete_page.dart';
import 'pages/camera_permission_page.dart';
import 'pages/camera_home_page.dart';
import 'pages/documents_page.dart';
import 'widgets/boot_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Show app immediately - defer heavy initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WriteOne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern theme with beautiful colors and Migra font
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Migra', // Set Migra as default font
        
        // Customize AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Customize Card theme
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Customize ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const BootScreen(), // Use BootScreen for initialization
      routes: {
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/email-verification': (context) => const EmailVerificationPage(),
        '/verification-complete': (context) => const VerificationCompletePage(),
        '/camera-permission': (context) => const CameraPermissionPage(),
        '/camera-home': (context) => const CameraHomePage(),
        '/documents': (context) => const DocumentsPage(),
      },
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
      },
    );
  }
}

