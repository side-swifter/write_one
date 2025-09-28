import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../services/mongo_service.dart';
import '../services/simple_vision_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './text_analysis_page.dart';

class ImageAnalysisPage extends StatefulWidget {
  final String imagePath;
  
  const ImageAnalysisPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageAnalysisPage> createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _textController;
  late Animation<double> _progressAnimation;
  
  int _currentTextIndex = 0;
  final List<String> _analysisTexts = [
    'Connecting to Google Vision...',
    'Extracting text from image...',
    'Analyzing document structure...',
    'Processing OCR results...',
  ];
  
  Timer? _textTimer;
  Timer? _progressTimer;
  String _extractedText = '';
  double _ocrConfidence = 0.0;
  Map<String, dynamic>? _analysisResults;

  @override
  void initState() {
    super.initState();
    
    // Initialize progress animation
    _progressController = AnimationController(
      duration: const Duration(seconds: 6), // Total analysis time
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _startAnalysis();
  }

  void _startAnalysis() {
    // Start progress animation
    _progressController.forward();
    
    // Start saving image to MongoDB
    _saveImageToMongo();
    
    // Cycle through analysis texts every 2 seconds
    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _analysisTexts.length;
        });
      }
    });
    
    // Complete analysis after 6 seconds
    _progressTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        // Navigate to results page or back
        _completeAnalysis();
      }
    });
  }
  
  Future<void> _saveImageToMongo() async {
    try {
      // Get current user ID from Supabase
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? 'demo_user'; // Fallback for demo
      
      print('🔄 Starting OCR analysis and saving to MongoDB for user: $userId');
      
      // Perform OCR analysis first
      final file = File(widget.imagePath);
      if (await file.exists()) {
        try {
          final visionService = SimpleVisionService.instance;
          
          // Extract text
          _extractedText = await visionService.extractTextFromImage(file);
          
          // Get structured analysis
          _analysisResults = await visionService.extractStructuredText(file);
          _ocrConfidence = _analysisResults?['confidence'] ?? 0.0;
          
          print('✅ OCR completed: ${_extractedText.length} chars, ${(_ocrConfidence * 100).toStringAsFixed(1)}% confidence');
        } catch (ocrError) {
          print('⚠️ OCR failed: $ocrError');
          // Continue with saving even if OCR fails
        }
      }
      
      // Save to MongoDB (this will also perform OCR again, but that's okay for redundancy)
      final imageId = await MongoService.instance.saveImageToGridFS(
        imagePath: widget.imagePath,
        userId: userId,
        metadata: {
          'analysisStarted': DateTime.now().toIso8601String(),
          'source': 'camera_capture',
        },
      );
      
      if (imageId != null) {
        print('✅ Image and OCR results saved to MongoDB with ID: $imageId');
      } else {
        print('❌ Failed to save image to MongoDB');
      }
    } catch (e) {
      print('❌ Error in analysis and save process: $e');
    }
  }

  void _completeAnalysis() {
    // Navigate to text analysis page with OCR results
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TextAnalysisPage(
          extractedText: _extractedText,
          confidence: _ocrConfidence,
          imagePath: widget.imagePath,
          analysisResults: _analysisResults,
        ),
      ),
    );
  }

  void _cancelAnalysis() {
    _textTimer?.cancel();
    _progressTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _textController.dispose();
    _textTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Image Display Area
              Expanded(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imagePath.isNotEmpty
                        ? Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Analysis Text
              Text(
                _analysisTexts[_currentTextIndex],
                style: const TextStyle(
                  fontFamily: 'Migra',
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Progress Bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[700],
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFFBEFF00), // Bright green
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Progress Percentage
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Migra',
                      color: Colors.grey,
                      fontSize: 24, // Bigger percentage text
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 2),
              
              // Cancel Button
              SizedBox(
                width: 120,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cancelAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White background
                    foregroundColor: Colors.black, // Black text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Migra',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
