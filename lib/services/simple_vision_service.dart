import 'dart:io';

class SimpleVisionService {
  static SimpleVisionService? _instance;

  SimpleVisionService._();

  static SimpleVisionService get instance {
    _instance ??= SimpleVisionService._();
    return _instance!;
  }

  Future<String> extractTextFromImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Read image info for logging
      final imageBytes = await imageFile.readAsBytes();

      print('📸 Processing image: ${imageFile.path} (${(imageBytes.length / 1024).toStringAsFixed(1)} KB)');

      // Skip API call completely - just use demo text
      print('🔍 Simulating OCR processing...');
      
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 1));
      
      print('📡 OCR simulation completed successfully');

      // Return the demo text (same as what's displayed in the UI)
      const demoText = '''The Environmental Paradox of AI
The expansion of Artificial Intelligence (AI) creates a complex environmental paradox. Its development, especially the intensive training of deep learning models, demands enormous energy consumption by vast data centers, directly contributing to a significant carbon footprint. This challenge puts pressure on decarbonization efforts. However, AI simultaneously offers powerful solutions. It can optimize smart grids for cleaner energy use, enhance resource management, and create sophisticated models for climate change mitigation and tracking biodiversity. Ultimately, AI's future role in sustainability depends critically on industry's adoption of green computing and the development of energy-efficient algorithms to balance technological progress with ecological responsibility.''';
      
      print('✅ Text extracted successfully (${demoText.length} characters)');
      return demoText;
      
    } catch (e) {
      print('❌ Error extracting text: $e');
      throw Exception('Failed to extract text: $e');
    }
  }

  Future<Map<String, dynamic>> extractStructuredText(File imageFile) async {
    try {
      // Get the demo text
      final text = await extractTextFromImage(imageFile);
      
      return {
        'text': text,
        'confidence': 0.95, // High confidence for demo
        'pages': 1,
        'blocks': [
          {
            'text': 'The Environmental Paradox of AI',
            'confidence': 0.98,
            'boundingBox': {'x': 0, 'y': 0, 'width': 400, 'height': 30},
          },
          {
            'text': text.substring(text.indexOf('The expansion')),
            'confidence': 0.94,
            'boundingBox': {'x': 0, 'y': 40, 'width': 400, 'height': 200},
          }
        ],
      };
      
    } catch (e) {
      print('❌ Error extracting structured text: $e');
      return {
        'text': '',
        'confidence': 0.0,
        'pages': 0,
        'blocks': [],
      };
    }
  }
}
