import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/mongo_service.dart';
import 'auth_wrapper.dart';

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    // Defer heavy initialization until after first frame paints
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      // Initialize Supabase
      setState(() => _status = 'Connecting to Supabase...');
      await Supabase.initialize(
        url: 'https://jqoptdeozjqzkfizzngm.supabase.co',
        anonKey: 'sb_secret_qiHUriBNdzNagk0VnJ2_bg_JMUKW3pB',
      );
      
      // Initialize MongoDB
      setState(() => _status = 'Connecting to MongoDB...');
      await MongoService.instance.connect();
      
      // Initialization complete
      setState(() => _status = 'Ready!');
      
      // Small delay to show "Ready!" then navigate
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navigate to the main app (AuthWrapper)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        ),
      );
    } catch (e) {
      print('❌ Bootstrap error: $e');
      setState(() {
        _status = 'Initialization failed. Continuing anyway...';
      });
      
      // Continue to app even if initialization fails
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/Loading one.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 40),
            
            // App Name
            const Text(
              'WriteOne',
              style: TextStyle(
                fontFamily: 'Migra',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFFBEFF00),
                strokeWidth: 3,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Status Text
            Text(
              _status,
              style: const TextStyle(
                fontFamily: 'Migra',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
