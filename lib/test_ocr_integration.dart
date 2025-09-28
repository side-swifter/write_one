import 'dart:io';
import '../services/simple_vision_service.dart';
import '../services/mongo_service.dart';
import '../config/google_cloud_config.dart';

// Simple test function to verify OCR integration
Future<void> testOCRIntegration() async {
  print('🧪 Testing OCR Integration...\n');
  
  // 1. Test Google Cloud Configuration
  print('1️⃣ Checking Google Cloud Configuration...');
  if (GoogleCloudConfig.isConfigured) {
    print('✅ Google Cloud credentials configured');
    print('   Project: ${GoogleCloudConfig.projectId}');
  } else {
    print('❌ Google Cloud credentials not configured');
    return;
  }
  
  // 2. Test Vision Service Initialization
  print('\n2️⃣ Testing Vision Service...');
  try {
    SimpleVisionService.instance;
    print('✅ Vision service initialized');
  } catch (e) {
    print('❌ Vision service failed: $e');
    return;
  }
  
  // 3. Test MongoDB Connection
  print('\n3️⃣ Testing MongoDB Connection...');
  try {
    await MongoService.instance.connect();
    if (MongoService.instance.isConnected) {
      print('✅ MongoDB connected');
    } else {
      print('⚠️ MongoDB not connected (OCR will still work)');
    }
  } catch (e) {
    print('⚠️ MongoDB connection issue: $e');
  }
  
  print('\n🎯 OCR Integration Test Complete!');
  print('\n📝 Next Steps:');
  print('   1. Take a photo in your app');
  print('   2. Watch console for OCR processing logs');
  print('   3. Check MongoDB for saved text data');
}

// Test with a sample image (if you have one)
Future<void> testWithSampleImage(String imagePath) async {
  print('🖼️ Testing OCR with image: $imagePath');
  
  final file = File(imagePath);
  if (!await file.exists()) {
    print('❌ Image not found: $imagePath');
    return;
  }
  
  try {
    final visionService = SimpleVisionService.instance;
    
    print('🔍 Extracting text...');
    final text = await visionService.extractTextFromImage(file);
    
    if (text.isNotEmpty) {
      print('   Length: ${text.length} characters');
    } else {
      print('⚠️ No text found in image');
    }
    
    // Test saving to database
    if (MongoService.instance.isConnected) {
      print('💾 Saving to database...');
      final imageId = await MongoService.instance.saveImageToGridFS(
        imagePath: imagePath,
        userId: 'test_user',
      );
      
      if (imageId != null) {
        print('✅ Saved to database with ID: $imageId');
      }
    }
    
  } catch (e) {
    print('❌ OCR test failed: $e');
  }
}
