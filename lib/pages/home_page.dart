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
              top: -122, // Move much higher up
              right: -100, // Position at right edge
              child: Transform.scale(
                scale: 2, // Large scale
                alignment: Alignment.topRight, // Scale from top-right corner
                child: Image.asset(
                  'assets/images/Hand.png',
                  height: 245,
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
                  const Spacer(flex: 4), // Space at top
                  
                  // Logo Section
                  Expanded(
                    flex: 6, // Space for logos
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Write One Logo
                        Flexible(
                          child: Image.asset(
                            'assets/images/Write One Text.png',
                            height: 200, // Reduced height
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        const SizedBox(height: 16), // Gap between logos
                        
                        // Auth at Glance Logo
                        Flexible(
                          child: Image.asset(
                            'assets/images/auth at glance.png',
                            height: 100, // Smaller height for tagline
                            fit: BoxFit.contain,
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
                                fontFamily: 'Migra',
                                fontSize: 16,
                                fontWeight: FontWeight.w600, // Use Migra Extrabold
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
                                fontFamily: 'Migra',
                                fontSize: 16,
                                fontWeight: FontWeight.w600, // Use Migra Extrabold
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
