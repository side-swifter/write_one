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
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Write One',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 64, // Larger font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0, // Add letter spacing
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle - Spanning width
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Authenticity at a Glance.',
                              style: TextStyle(
                                fontSize: 22, // Slightly larger
                                color: Colors.grey[400], // Lighter grey
                                fontWeight: FontWeight.w300, // Lighter weight
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Get started button (white)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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
                  
                  // Login button (green)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
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
