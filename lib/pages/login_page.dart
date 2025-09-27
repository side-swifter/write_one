import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D), // Dark background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Login Title
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Username Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Password Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate inputs
                    if (_usernameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (_passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      print('Attempting login with email: ${_usernameController.text.trim()}');
                      
                      final user = await AuthService.loginWithEmail(
                        _usernameController.text.trim(),
                        _passwordController.text,
                      );
                      
                      print('Login result: ${user?.email ?? 'null'}');
                      
                      if (user != null) {
                        print('Login successful, navigating to profile');
                        Navigator.pushReplacementNamed(context, '/profile');
                      } else {
                        print('Login returned null user');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login failed - no user returned'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      print('Login error: $e');
                      String errorMessage = e.toString();
                      
                      // Clean up the error message
                      if (errorMessage.startsWith('Exception: ')) {
                        errorMessage = errorMessage.substring(11);
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEFF00), // Bright green
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Or login with divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[600])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '-----Or login with-----',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[600])),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Google Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final user = await AuthService.loginWithGoogle();
                      if (user != null) {
                        Navigator.pushReplacementNamed(context, '/profile');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28), // Pill shape
                    ),
                    elevation: 1,
                    shadowColor: Colors.grey.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google icon
                      Image.network(
                        'https://developers.google.com/identity/images/g-logo.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 12), // Space between icon and text
                      // Text
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Forgot Password
              TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              
              // Click Here link
              TextButton(
                onPressed: () {
                  // Handle click here action
                },
                child: const Text(
                  'Click Here',
                  style: TextStyle(
                    color: Color(0xFFBEFF00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Back Button
              SizedBox(
                width: 120,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEFF00), // Bright green
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
