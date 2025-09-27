import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D), // Dark background
      body: SafeArea(
        child: Stack(
          children: [
            // Hand Image positioned at absolute top right of screen
            Positioned(
              top: -120, // Move much higher up
              right: -100, // Position at right edge
              child: Transform.scale(
                scale: 2, // Large scale
                alignment: Alignment.topRight, // Scale from top-right corner
                child: Image.asset(
                  'assets/images/Hand.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 5), // More space at top
                  
                  // Logo, Title, and Subtitle Section
                  Expanded(
                    flex: 3, // Less space for text section
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Write One Text - Centered horizontally
                        Center(
                          child: FittedBox(
                            child: Text(
                              'Write One',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 64, // Larger font size
                                fontWeight: FontWeight.w900, // Extra bold
                                color: Colors.white,
                                letterSpacing: -2, // Tighter letter spacing
                                height: 0.9, // Tighter line height
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8), // Small gap
                        
                        // Subtitle - Centered
                        const Text(
                          'Authenticity at a Glance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Buttons Section
                  Expanded(
                    flex: 2, // More space for buttons
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
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
                              'Get started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                      ],
                    ),
                  ),
                  
                  // Bottom spacing
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
