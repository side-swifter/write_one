import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/home_page.dart';
import '../pages/documents_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        setState(() {
          _isAuthenticated = true;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          _isAuthenticated = false;
        });
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      
      setState(() {
        _isAuthenticated = session != null && user != null;
        _isLoading = false;
      });
      
      print('🔐 Auth Status: ${_isAuthenticated ? "Authenticated" : "Not authenticated"}');
      if (user != null) {
        print('👤 User: ${user.email}');
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFBEFF00),
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontFamily: 'Migra',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If authenticated, go to documents page (main app)
    // If not authenticated, go to home page (login/signup)
    return _isAuthenticated ? const DocumentsPage() : const HomePage();
  }
}
