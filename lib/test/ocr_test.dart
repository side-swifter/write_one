import 'dart:io';
import '../services/simple_vision_service.dart';
import '../services/mongo_service.dart';
import '../config/google_cloud_config.dart';

class OCRTest {
  
  static Future<void> testOCRSetup() async {
    print('🧪 Testing OCR Setup...\n');
    
    // 1. Test credentials configuration
    print('1️⃣ Testing Google Cloud Configuration...');
    if (GoogleCloudConfig.isConfigured) {
      print('✅ Google Cloud credentials are configured');
      print('   Project ID: ${GoogleCloudConfig.projectId}');
      print('   Service Account: ${GoogleCloudConfig.clientEmail}');
    } else {
      print('❌ Google Cloud credentials not configured');
      return;
    }
    
    // 2. Test Vision API initialization
    print('\n2️⃣ Testing Google Vision API...');
    try {
      SimpleVisionService.instance;
      print('✅ Google Vision service initialized');
    } catch (e) {
      print('❌ Failed to initialize Vision API: $e');
      return;
    }
    
    // 3. Test MongoDB Connection
    print('\n3️⃣ Testing MongoDB Connection...');
    try {
      await MongoService.instance.connect();
      if (MongoService.instance.isConnected) {
        print('✅ MongoDB connected successfully');
      } else {
        print('⚠️ MongoDB not connected (but OCR can still work)');
      }
    } catch (e) {
      print('⚠️ MongoDB connection failed: $e');
    }
    
    print('\n🎯 OCR Setup Test Complete!');
    print('📝 Next steps:');
    print('   1. Take a photo with text in your app');
    print('   2. Check console for OCR extraction logs');
    print('   3. Verify text is saved to database');
  }
  
  static Future<void> testOCRWithSampleImage(String imagePath) async {
    print('🧪 Testing OCR with image: $imagePath\n');
    
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      print('❌ Image file not found: $imagePath');
      return;
    }
    
    try {
      print('📸 Image found: ${(await imageFile.length() / 1024).toStringAsFixed(1)} KB');
      
      // Test text extraction
      print('\n🔍 Extracting text...');
      final visionService = SimpleVisionService.instance;
      final extractedText = await visionService.extractTextFromImage(imageFile);
      
      if (extractedText.isNotEmpty) {
        print('✅ Text extracted successfully!');
        print('📄 Extracted text (${extractedText.length} chars):');
        print('   "${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}${extractedText.length > 100 ? "..." : ""}"');
      } else {
        print('⚠️ No text found in image');
      }
      
      // Test structured analysis
      print('\n📊 Getting detailed analysis...');
      final structuredResults = await visionService.extractStructuredText(imageFile);
      final confidence = structuredResults['confidence'] ?? 0.0;
      final blocks = structuredResults['blocks'] ?? [];
      
      print('✅ Analysis complete:');
      print('   Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
      print('   Text blocks: ${blocks.length}');
      print('   Pages: ${structuredResults['pages']}');
      
      // Test database save
      print('\n💾 Testing database save...');
      if (MongoService.instance.isConnected) {
        final imageId = await MongoService.instance.saveImageToGridFS(
          imagePath: imagePath,
          userId: 'test_user_123',
          metadata: {'source': 'ocr_test'},
        );
        
        if (imageId != null) {
          print('✅ Image and OCR results saved to database');
          print('   Document ID: $imageId');
        } else {
          print('❌ Failed to save to database');
        }
      } else {
        print('⚠️ Database not connected - skipping save test');
      }
      
    } catch (e) {
      print('❌ OCR test failed: $e');
    }
  }
  
  static void printOCRUsageInstructions() {
    print('📖 OCR Integration Usage Instructions:\n');
    
    print('🔧 Setup (Already Done):');
    print('   ✅ Google Cloud credentials configured');
    print('   ✅ Vision API service created');
    print('   ✅ MongoDB integration updated');
    
    print('\n📱 How it works in your app:');
    print('   1. User takes photo or selects from gallery');
    print('   2. Image is automatically processed with OCR');
    print('   3. Text is extracted using Google Vision API');
    print('   4. Both image AND text are saved to MongoDB');
    print('   5. Users can search documents by text content');
    
    print('\n🔍 Available features:');
    print('   • Text extraction from any image');
    print('   • Confidence scores for accuracy');
    print('   • Search documents by text content');
    print('   • OCR statistics and analytics');
    print('   • Structured text with blocks and positions');
    
    print('\n💡 Test your setup:');
    print('   await OCRTest.testOCRSetup();');
    print('   await OCRTest.testOCRWithSampleImage("/path/to/image.jpg");');
  }
}

// Quick test function you can call from anywhere
Future<void> quickOCRTest() async {
  await OCRTest.testOCRSetup();
  OCRTest.printOCRUsageInstructions();
}
