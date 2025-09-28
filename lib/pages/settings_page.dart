import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _enableAIAnalysis = true;
  bool _verifyDocuments = true;
  bool _notifications = true;
  bool _locationTracking = false;
  bool _dataSharing = false;
  
  // User data from Supabase
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      setState(() {
        // Get user name from metadata or email
        _userName = user.userMetadata?['full_name'] ?? 
                   user.userMetadata?['name'] ?? 
                   user.email?.split('@')[0] ?? 
                   'User';
        _userEmail = user.email ?? 'No email';
      });
    } else {
      setState(() {
        _userName = 'Guest User';
        _userEmail = 'Not logged in';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Migra',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontFamily: 'Migra',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontFamily: 'Migra',
                      color: Colors.grey[400],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Privacy Settings Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Enable AI Analysis
                  _buildToggleRow('Enable AI Analysis', _enableAIAnalysis, (value) {
                    setState(() {
                      _enableAIAnalysis = value;
                    });
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Verify Documents
                  _buildToggleRow('Verify Documents', _verifyDocuments, (value) {
                    setState(() {
                      _verifyDocuments = value;
                    });
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Notifications
                  _buildToggleRow('Notifications', _notifications, (value) {
                    setState(() {
                      _notifications = value;
                    });
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Location Tracking
                  _buildToggleRow('Location Tracking', _locationTracking, (value) {
                    setState(() {
                      _locationTracking = value;
                    });
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Data Sharing
                  _buildToggleRow('Data Sharing', _dataSharing, (value) {
                    setState(() {
                      _dataSharing = value;
                    });
                  }),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () async {
                  try {
                    await AuthService.logout();
                    // Navigate to home page after logout
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () {
                  _showDeleteAccountDialog();
                },
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
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
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[600],
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[700],
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion not implemented yet'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
