import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/gemini_service.dart';

// 🎯 EASY EDIT SECTION - Change these to customize your text and highlighting
class TextConfig {
  // Main text to display (edit this to change the content)
  static const String displayText = '''The Environmental Paradox of AI
The expansion of Artificial Intelligence (AI) creates a complex environmental paradox. Its development, especially the intensive training of deep learning models, demands enormous energy consumption by vast data centers, directly contributing to a significant carbon footprint. This challenge puts pressure on decarbonization efforts. However, AI simultaneously offers powerful solutions. It can optimize smart grids for cleaner energy use, enhance resource management, and create sophisticated models for climate change mitigation and tracking biodiversity. Ultimately, AI's future role in sustainability depends critically on industry's adoption of green computing and the development of energy-efficient algorithms to balance technological progress with ecological responsibility.''';
  
  // Keywords to highlight in green (add/remove words here)
  static const List<String> highlightKeywords = [
    'The expansion of Artificial Intelligence (AI) creates a complex environmental paradox. Its development, especially the intensive training of deep learning models, demands enormous energy consumption by vast data centers, directly contributing to a significant carbon footprint. This challenge puts pressure on decarbonization efforts.',
    'and create sophisticated models for climate change mitigation and tracking biodiversity. Ultimately, AI\'s future role in sustainability depends critically on industry\'s adoption of green computing and the development of energy-efficient algorithms to balance technological progress'
  ];
  
  // Error message when no text is found
  static const String errorMessage = 'ERROR NO TEXT IN IMAGE, PLEASE TRY AGAIN';
}

class TextAnalysisPage extends StatefulWidget {
  final String extractedText;
  final double confidence;
  final String imagePath;
  final Map<String, dynamic>? analysisResults;
  final String source; // 'shutter' or 'gallery'

  const TextAnalysisPage({
    super.key,
    required this.extractedText,
    required this.confidence,
    required this.imagePath,
    this.analysisResults,
    required this.source,
  });

  @override
  State<TextAnalysisPage> createState() => _TextAnalysisPageState();
}

class _TextAnalysisPageState extends State<TextAnalysisPage> 
    with TickerProviderStateMixin {
  
  // Animation controllers
  AnimationController? _typewriterController;
  AnimationController? _cursorController;
  AnimationController? _fadeController;
  Animation<int>? _typewriterAnimation;
  Animation<double>? _cursorAnimation;
  Animation<double>? _fadeAnimation;
  
  // Current text being displayed (for typewriter effect)
  String _currentDisplayText = '';
  
  // Gemini analysis results
  GeminiAnalysisResult? _geminiResult;
  bool _geminiAnalysisComplete = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize typewriter animation
    _typewriterController = AnimationController(
      duration: const Duration(seconds: 4), // 4 seconds to type all text
      vsync: this,
    );
    
    // Initialize cursor blinking animation
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Initialize fade animation for analysis sections
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    final textToDisplay = _getDisplayText();
    _typewriterAnimation = IntTween(
      begin: 0,
      end: textToDisplay.length,
    ).animate(CurvedAnimation(
      parent: _typewriterController!,
      curve: Curves.easeInOut,
    ));
    
    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_cursorController!);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    ));
    
    _typewriterAnimation!.addListener(() {
      setState(() {
        final textToDisplay = _getDisplayText();
        _currentDisplayText = textToDisplay.substring(
          0, 
          _typewriterAnimation!.value.clamp(0, textToDisplay.length)
        );
      });
    });
    
    // Start cursor blinking immediately
    _cursorController!.repeat(reverse: true);
    
    // Start the typewriter animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _typewriterController!.forward().then((_) {
          // Stop cursor blinking when typing is done
          _cursorController!.stop();
        });
      }
    });
    
    // Start fade animation for analysis sections after 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _fadeController!.forward();
      }
    });
    
    // Start Gemini analysis for gallery images
    if (widget.source == 'gallery') {
      _analyzeWithGemini();
    }
  }
  
  Future<void> _analyzeWithGemini() async {
    try {
      print('🤖 Starting Gemini analysis...');
      final textToAnalyze = _getDisplayText();
      
      final result = await GeminiService.instance.analyzeTextForAI(textToAnalyze);
      
      if (mounted) {
        setState(() {
          _geminiResult = result;
          _geminiAnalysisComplete = true;
        });
        print('✅ Gemini analysis complete: ${result.aiPercentage}% AI-generated');
      }
    } catch (e) {
      print('❌ Gemini analysis failed: $e');
      if (mounted) {
        setState(() {
          _geminiAnalysisComplete = true;
          // Keep default values if analysis fails
        });
      }
    }
  }
  
  @override
  void dispose() {
    _typewriterController?.dispose();
    _cursorController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Extracted Text
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - always use configured text for demo
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Extracted Text with highlighting
                  Expanded(
                    child: SingleChildScrollView(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.6,
                          ),
                          children: _buildHighlightedText(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side - Analysis
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                child: Column(
                  children: [
                    // Confidence Indicator (without Analysis text)
                    _buildConfidenceIndicatorOnly(),
                    
                    const SizedBox(height: 30),
                    
                    // Analysis text positioned right above Overall Analysis box
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 5),
                    
                    // Overall Analysis
                    _buildOverallAnalysis(),
                    
                    const SizedBox(height: 20),
                    
                    // Analysis Results
                    Expanded(
                      child: _buildAnalysisResults(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicatorOnly() {
    return Container(
      height: 120,
      child: Stack(
        children: [
          // Semi-circular progress indicator
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: SemiCircularProgressPainter(
                  progress: _getProgressValue(),
                ),
              ),
            ),
          ),
          
          // 95% AI Generated text on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getAIPercentageText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.source == 'shutter' ? 'Text Found' : 'AI Generated',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    // If shutter button was used, show error message
    if (widget.source == 'shutter') {
      return TextConfig.errorMessage;
    }
    // If gallery was used, show mock overview
    return TextConfig.displayText;
  }

  String _getTitle() {
    final textToDisplay = _getDisplayText();
    final lines = textToDisplay.split('\n');
    final firstLine = lines.isNotEmpty ? lines[0] : textToDisplay;
    
    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 50)}...';
    }
    return firstLine;
  }

  String _getAIPercentageText() {
    if (widget.source == 'shutter') {
      return '0%';
    }
    
    if (_geminiResult != null) {
      return '${_geminiResult!.aiPercentage.round()}%';
    }
    
    return _geminiAnalysisComplete ? '95%' : '...';
  }

  String _getOverallAnalysisTitle() {
    if (widget.source == 'shutter') {
      return 'No Text Found';
    }
    
    if (_geminiResult != null) {
      final percentage = _geminiResult!.aiPercentage.round();
      return '$percentage% AI Generated';
    }
    
    return _geminiAnalysisComplete ? '95% AI Generated' : 'Analyzing...';
  }

  String _getOverallAnalysisDescription() {
    if (widget.source == 'shutter') {
      return 'No readable text was detected in the captured image';
    }
    
    if (_geminiResult != null && _geminiResult!.reasoning.isNotEmpty) {
      return _geminiResult!.reasoning;
    }
    
    return _geminiAnalysisComplete 
        ? 'This text is most likely to be AI generated, or contain AI Generated Content'
        : 'Analyzing text with AI to detect generated content...';
  }

  double _getProgressValue() {
    if (widget.source == 'shutter') {
      return 0.0;
    }
    
    if (_geminiResult != null) {
      return _geminiResult!.aiPercentage / 100.0;
    }
    
    return _geminiAnalysisComplete ? 0.95 : widget.confidence;
  }

  List<TextSpan> _buildHighlightedText() {
    // Use the animated text that's being typed out
    final text = _currentDisplayText;
    
    // If shutter button was used, don't highlight anything (error message)
    if (widget.source == 'shutter') {
      return [TextSpan(
        text: text,
        style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
      )];
    }
    
    // If Gemini analysis is complete and we have results, use them
    if (_geminiResult != null && _geminiResult!.aiGeneratedParts.isNotEmpty) {
      return _buildGeminiHighlightedText(text, _geminiResult!.aiGeneratedParts);
    }
    
    // Show analysis in progress or fall back to default highlighting
    if (!_geminiAnalysisComplete) {
      // Show text without highlighting while analysis is in progress
      return [
        TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white),
        ),
        if (_typewriterController?.isAnimating == true)
          TextSpan(
            text: '|',
            style: TextStyle(
              color: Color(0xFFBEFF00).withValues(alpha: _cursorAnimation?.value ?? 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
      ];
    }
    
    // Fall back to default highlighting if Gemini analysis failed
    return _buildDefaultHighlightedText(text, TextConfig.highlightKeywords);
  }

  List<TextSpan> _buildGeminiHighlightedText(String text, List<String> aiParts) {
    List<TextSpan> spans = [];
    String remainingText = text;
    
    // Sort AI parts by their position in the text to highlight in order
    List<String> sortedAiParts = List.from(aiParts);
    sortedAiParts.sort((a, b) {
      int indexA = text.toLowerCase().indexOf(a.toLowerCase());
      int indexB = text.toLowerCase().indexOf(b.toLowerCase());
      return indexA.compareTo(indexB);
    });
    
    for (String aiPart in sortedAiParts) {
      if (remainingText.isEmpty) break;
      
      int index = remainingText.toLowerCase().indexOf(aiPart.toLowerCase());
      if (index != -1) {
        // Add text before the AI part
        if (index > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, index),
            style: const TextStyle(color: Colors.white),
          ));
        }
        
        // Add the highlighted AI part
        final actualAiPart = remainingText.substring(index, index + aiPart.length);
        spans.add(TextSpan(
          text: actualAiPart,
          style: const TextStyle(
            color: Color(0xFFBEFF00),
            backgroundColor: Color(0x33BEFF00), // Subtle background highlight
            fontWeight: FontWeight.w500,
          ),
        ));
        
        remainingText = remainingText.substring(index + aiPart.length);
      }
    }
    
    // Add any remaining text
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(
        text: remainingText,
        style: const TextStyle(color: Colors.white),
      ));
    }
    
    // Add blinking cursor at the end if animation is still running
    if (_typewriterController?.isAnimating == true) {
      spans.add(TextSpan(
        text: '|',
        style: TextStyle(
          color: Color(0xFFBEFF00).withValues(alpha: _cursorAnimation?.value ?? 1.0),
          fontWeight: FontWeight.bold,
        ),
      ));
    }
    
    return spans;
  }

  List<TextSpan> _buildDefaultHighlightedText(String text, List<String> keywords) {
    List<TextSpan> spans = [];
    String remainingText = text;
    
    while (remainingText.isNotEmpty) {
      int earliestIndex = remainingText.length;
      String foundWord = '';
      
      // Find the earliest occurrence of any keyword
      for (String keyword in keywords) {
        int index = remainingText.toLowerCase().indexOf(keyword.toLowerCase());
        if (index != -1 && index < earliestIndex) {
          earliestIndex = index;
          foundWord = keyword;
        }
      }
      
      if (foundWord.isNotEmpty && earliestIndex < remainingText.length) {
        // Add text before the keyword
        if (earliestIndex > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, earliestIndex),
            style: const TextStyle(color: Colors.white),
          ));
        }
        
        // Add the highlighted keyword
        final actualWord = remainingText.substring(earliestIndex, earliestIndex + foundWord.length);
        spans.add(TextSpan(
          text: actualWord,
          style: const TextStyle(color: Color(0xFFBEFF00)),
        ));
        
        remainingText = remainingText.substring(earliestIndex + foundWord.length);
      } else {
        // No more keywords found, add remaining text
        spans.add(TextSpan(
          text: remainingText,
          style: const TextStyle(color: Colors.white),
        ));
        break;
      }
    }
    
    // Add blinking cursor at the end if animation is still running
    if (_typewriterController?.isAnimating == true) {
      spans.add(TextSpan(
        text: '|',
        style: TextStyle(
          color: Color(0xFFBEFF00).withValues(alpha: _cursorAnimation?.value ?? 1.0),
          fontWeight: FontWeight.bold,
        ),
      ));
    }
    
    return spans;
  }

  Widget _buildOverallAnalysis() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Analysis',
            style: TextStyle(
              color: Color(0xFFBEFF00),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getOverallAnalysisTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getOverallAnalysisDescription(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnalysisResult(
            '2',
            'Text structure analysis: ${widget.extractedText.isNotEmpty ? "Well-formatted content detected" : "No content to analyze"}',
          ),
          const SizedBox(height: 12),
          _buildAnalysisResult(
            '3',
            'Language patterns: ${widget.extractedText.length > 100 ? "Complex vocabulary usage" : "Simple text structure"}',
          ),
          const SizedBox(height: 12),
          _buildAnalysisResult(
            '4',
            'Content analysis: ${widget.extractedText.isNotEmpty ? "Readable text extracted successfully" : "No readable content found"}',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(String number, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Result $number',
            style: const TextStyle(
              color: Color(0xFFBEFF00),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share Text', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.white),
              title: const Text('Save as Document', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement save functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit Text', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement edit functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the semi-circular progress indicator
class SemiCircularProgressPainter extends CustomPainter {
  final double progress;

  SemiCircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFFBEFF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
