import 'package:flutter/material.dart';
import '../services/mongo_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Map<String, dynamic>> _userDocuments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserDocuments();
  }

  Future<void> _loadUserDocuments() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Get current user ID
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? 'demo_user';

      print('🔍 Loading documents for user: $userId');

      // Get user's images from MongoDB GridFS
      final documents = await MongoService.instance.getUserImages(userId);

      // Add mock AI detection percentages for demo
      final documentsWithAI = documents.map((doc) {
        return {
          ...doc,
          'aiPercentage': _generateMockAIPercentage(),
        };
      }).toList();

      setState(() {
        _userDocuments = documentsWithAI;
        _loading = false;
      });

      print('✅ Loaded ${documents.length} documents');
    } catch (e) {
      print('❌ Error loading documents: $e');
      setState(() {
        _error = 'Failed to load documents: $e';
        _loading = false;
      });
    }
  }

  int _generateMockAIPercentage() {
    // Generate random AI detection percentage for demo
    final percentages = [30, 50, 70];
    percentages.shuffle();
    return percentages.first;
  }

  Color _getAIPercentageColor(int percentage) {
    if (percentage >= 70) return Colors.red;
    if (percentage >= 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFBEFF00),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Text(
                'Documents',
                style: TextStyle(
                  fontFamily: 'Migra',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Welcome Back Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Welcome Back',
                style: TextStyle(
                  fontFamily: 'Migra',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Documents List
            Expanded(
              child: _buildDocumentsList(),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Documents Icon (Current - Active State)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  // Camera Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/camera-home');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  
                  // Settings Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFBEFF00)),
            SizedBox(height: 20),
            Text(
              'Loading your documents...',
              style: TextStyle(
                fontFamily: 'Migra',
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'Migra',
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBEFF00),
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Migra',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_userDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 20),
            const Text(
              'No documents yet',
              style: TextStyle(
                fontFamily: 'Migra',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Take a photo to get started!',
              style: TextStyle(
                fontFamily: 'Migra',
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/camera-home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBEFF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Take Photo',
                style: TextStyle(
                  fontFamily: 'Migra',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _userDocuments.length,
      itemBuilder: (context, index) {
        final document = _userDocuments[index];
        final aiPercentage = document['aiPercentage'] as int;
        final documentName = document['originalName'] ?? 'Document ${index + 1}';
        final extractedText = document['extractedText'] ?? '';
        final hasText = document['hasText'] ?? false;
        final ocrConfidence = document['ocrConfidence'] ?? 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Document Name
                  Expanded(
                    child: Text(
                      documentName.replaceAll('.jpg', '').replaceAll('.png', ''),
                      style: const TextStyle(
                        fontFamily: 'Migra',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // OCR Status Badge
                  if (hasText)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEFF00).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(ocrConfidence * 100).toStringAsFixed(0)}% OCR',
                        style: const TextStyle(
                          color: Color(0xFFBEFF00),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  
                  // AI Percentage
                  Text(
                    '${aiPercentage}% AI',
                    style: TextStyle(
                      fontFamily: 'Migra',
                      color: _getAIPercentageColor(aiPercentage),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              // Text Preview
              if (hasText && extractedText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  extractedText.length > 80 
                    ? '${extractedText.substring(0, 80)}...'
                    : extractedText,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ] else if (!hasText) ...[
                const SizedBox(height: 8),
                const Text(
                  'No text detected in this image',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEFF00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontFamily: 'Migra',
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
