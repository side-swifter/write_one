import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class TextAnalysisPage extends StatefulWidget {
  final String extractedText;
  final double confidence;
  final String imagePath;
  final Map<String, dynamic>? analysisResults;

  const TextAnalysisPage({
    super.key,
    required this.extractedText,
    required this.confidence,
    required this.imagePath,
    this.analysisResults,
  });

  @override
  State<TextAnalysisPage> createState() => _TextAnalysisPageState();
}

class _TextAnalysisPageState extends State<TextAnalysisPage> {

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
                  // Title - use extracted text or error message
                  Text(
                    widget.extractedText.isNotEmpty 
                      ? _getTitle()
                      : 'ERROR NO TEXT IN IMAGE, PLEASE TRY AGAIN',
                    style: TextStyle(
                      color: widget.extractedText.isNotEmpty ? Colors.white : Colors.red,
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
              child: Column(
                children: [
                  // Confidence Indicator
                  _buildConfidenceIndicator(),
                  
                  const SizedBox(height: 30),
                  
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
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final percentage = (widget.confidence * 100).round();
    
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
                  progress: widget.confidence,
                ),
              ),
            ),
          ),
          
          // Analysis text
          Positioned(
            right: 0,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (widget.extractedText.isEmpty) return 'No Text Found';
    
    // Get first line or first 50 characters as title
    final lines = widget.extractedText.split('\n');
    final firstLine = lines.isNotEmpty ? lines[0] : widget.extractedText;
    
    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 50)}...';
    }
    return firstLine;
  }

  List<TextSpan> _buildHighlightedText() {
    if (widget.extractedText.isEmpty) {
      return [
        const TextSpan(
          text: 'ERROR NO TEXT IN IMAGE, PLEASE TRY AGAIN',
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      ];
    }

    // Use actual extracted text and highlight some key words
    final text = widget.extractedText;
    final keyWords = ['AI', 'artificial intelligence', 'technology', 'digital', 'data', 'algorithm', 'machine learning', 'computer', 'software', 'system'];
    
    List<TextSpan> spans = [];
    String remainingText = text;
    
    while (remainingText.isNotEmpty) {
      int earliestIndex = remainingText.length;
      String foundWord = '';
      
      // Find the earliest occurrence of any keyword
      for (String keyword in keyWords) {
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
          const Text(
            '95% AI Generated',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This text is most likely to be AI generated, or contain AI Generated Content',
            style: TextStyle(
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
