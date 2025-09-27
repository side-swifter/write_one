import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPermissionPage extends StatefulWidget {
  const CameraPermissionPage({super.key});

  @override
  State<CameraPermissionPage> createState() => _CameraPermissionPageState();
}

class _CameraPermissionPageState extends State<CameraPermissionPage> {
  bool _isRequestingPermission = false;

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      print('📷 Getting available cameras...');
      
      // Get available cameras - this is required first
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        print('❌ No cameras found on device');
        _showNoCameraDialog();
        return;
      }
      
      print('📱 Found ${cameras.length} camera(s)');
      print('🎥 Initializing camera controller to trigger permission...');
      
      // Initialize camera controller - this WILL trigger the Android permission dialog
      final controller = CameraController(
        cameras.first, // Use the first available camera
        ResolutionPreset.medium,
        enableAudio: false, // We don't need audio for photos
      );
      
      // This initialize() call will show the Android permission dialog
      await controller.initialize();
      
      print('✅ Camera permission granted! Controller initialized successfully.');
      
      // Clean up the controller since we only needed it for permission
      await controller.dispose();
      
      // Show success message briefly
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission granted!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
      
      // Wait a moment then navigate to home
      await Future.delayed(const Duration(milliseconds: 1500));
      _navigateToHome();
      
    } catch (e) {
      print('❌ Camera permission denied or error: $e');
      
      // Show permission denied message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission denied. You can still use the app!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Wait a moment then navigate to home anyway
      await Future.delayed(const Duration(milliseconds: 2000));
      _navigateToHome();
      
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'No Camera Found',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'No camera was detected on this device.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToHome();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBEFF00),
              foregroundColor: Colors.black,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/camera-home');
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
              
              // Camera Icon
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFFBEFF00), // Bright green
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Allow Camera Title
              const Text(
                'Allow Camera',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              const Text(
                'Click Allow when prompted for camera\naccess to take photos for your posts.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Click to Allow Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRequestingPermission ? null : _requestCameraPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEFF00), // Bright green
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isRequestingPermission
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Click to Allow',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Skip Button
              TextButton(
                onPressed: _navigateToHome,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
