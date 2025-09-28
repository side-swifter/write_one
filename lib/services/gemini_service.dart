import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiAnalysisResult {
  final double aiPercentage;
  final List<String> aiGeneratedParts;
  final String reasoning;
  final double confidence;

  GeminiAnalysisResult({
    required this.aiPercentage,
    required this.aiGeneratedParts,
    required this.reasoning,
    required this.confidence,
  });

  factory GeminiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return GeminiAnalysisResult(
      aiPercentage: (json['aiPercentage'] ?? 0.0).toDouble(),
      aiGeneratedParts: List<String>.from(json['aiGeneratedParts'] ?? []),
      reasoning: json['reasoning'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class GeminiService {
  static const String _apiKey = 'AIzaSyAQ.Ab8RN6IJWumgzQlffe-IC2CVyucutJbc2yWT4A27UfyHRxLWmQ';
  static GeminiService? _instance;
  late GenerativeModel _model;

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  GeminiService._() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Analyze text to detect AI-generated content
  Future<GeminiAnalysisResult> analyzeTextForAI(String text) async {
    try {
      print('🤖 Analyzing text with Gemini for AI detection...');
      
      final prompt = '''
Analyze the following text to determine if it contains AI-generated content. 

Text to analyze:
"$text"

Please provide your analysis in the following JSON format:
{
  "aiPercentage": <number between 0-100 representing percentage of AI-generated content>,
  "aiGeneratedParts": [<array of exact text snippets that appear to be AI-generated>],
  "reasoning": "<brief explanation of why you think certain parts are AI-generated>",
  "confidence": <number between 0-1 representing your confidence in this analysis>
}

Look for patterns typical of AI-generated text such as:
- Overly formal or structured language
- Repetitive phrasing patterns
- Lack of personal voice or opinion
- Generic statements without specific details
- Perfect grammar and syntax
- Buzzwords and corporate speak
- Balanced arguments without strong positions

Be precise in identifying the exact text snippets that seem AI-generated. Only return valid JSON.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null) {
        throw Exception('No response from Gemini');
      }

      print('📝 Gemini response: ${response.text}');
      
      // Parse JSON response
      final jsonString = response.text!.trim();
      
      // Clean up the response to extract JSON
      String cleanJson = jsonString;
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();
      
      final jsonData = jsonDecode(cleanJson);
      final result = GeminiAnalysisResult.fromJson(jsonData);
      
      print('✅ Gemini analysis complete: ${result.aiPercentage}% AI-generated');
      return result;
      
    } catch (e) {
      print('❌ Error analyzing text with Gemini: $e');
      
      // Return fallback result
      return GeminiAnalysisResult(
        aiPercentage: 50.0,
        aiGeneratedParts: [],
        reasoning: 'Analysis failed, using fallback result',
        confidence: 0.1,
      );
    }
  }

  /// Analyze text and provide detailed breakdown
  Future<Map<String, dynamic>> getDetailedAnalysis(String text) async {
    try {
      final result = await analyzeTextForAI(text);
      
      return {
        'aiPercentage': result.aiPercentage,
        'confidence': result.confidence,
        'aiGeneratedParts': result.aiGeneratedParts,
        'reasoning': result.reasoning,
        'humanParts': _extractHumanParts(text, result.aiGeneratedParts),
      };
    } catch (e) {
      print('❌ Error getting detailed analysis: $e');
      return {
        'aiPercentage': 50.0,
        'confidence': 0.1,
        'aiGeneratedParts': <String>[],
        'reasoning': 'Analysis failed',
        'humanParts': <String>[],
      };
    }
  }

  /// Extract parts of text that are likely human-written
  List<String> _extractHumanParts(String fullText, List<String> aiParts) {
    String remainingText = fullText;
    List<String> humanParts = [];
    
    // Remove AI parts from the full text
    for (String aiPart in aiParts) {
      remainingText = remainingText.replaceAll(aiPart, '|||SPLIT|||');
    }
    
    // Split and clean up human parts
    humanParts = remainingText
        .split('|||SPLIT|||')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && part.length > 10)
        .toList();
    
    return humanParts;
  }
}
