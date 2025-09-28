import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/database_config.dart';

class MongoService {
  static MongoService? _instance;
  static MongoService get instance => _instance ??= MongoService._();
  
  MongoService._();
  
  Db? _db;
  GridFS? _gridFS;
  
  // Use connection string from config
  String get _connectionString => DatabaseConfig.connectionString;
  
  Future<void> connect() async {
    try {
      _db = await Db.create(_connectionString);
      await _db!.open();
      
      // Initialize GridFS for image storage
      _gridFS = GridFS(_db!, 'images');
      
      print('✅ Connected to MongoDB successfully');
    } catch (e) {
      print('❌ Failed to connect to MongoDB: $e');
      // For demo purposes, we'll continue without MongoDB
      // In production, you'd want to handle this more gracefully
    }
  }
  
  Future<void> disconnect() async {
    await _db?.close();
    _db = null;
    _gridFS = null;
  }
  
  bool get isConnected => _db != null && _db!.isConnected;
  
  Future<String?> saveImageToGridFS({
    required String imagePath,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!isConnected || _gridFS == null) {
      print('❌ MongoDB not connected');
      return null;
    }
    
    try {
      // Read the image file
      final file = File(imagePath);
      if (!await file.exists()) {
        print('❌ Image file does not exist: $imagePath');
        return null;
      }
      
      final imageBytes = await file.readAsBytes();
      final fileName = imagePath.split('/').last;
      
      // Prepare metadata for GridFS
      final fileMetadata = {
        'userId': userId,
        'originalName': fileName,
        'contentType': _getContentType(fileName),
        'uploadedAt': DateTime.now().toIso8601String(),
        'fileSize': imageBytes.length,
        ...?metadata,
      };
      
      // Create GridFS file and save
      final gridIn = _gridFS!.createFile(Stream.fromIterable([imageBytes]), fileName);
      gridIn.metaData = fileMetadata;
      
      final objectId = await gridIn.save();
      
      print('✅ Image saved to GridFS with ID: $objectId');
      return objectId.toString();
      
    } catch (e) {
      print('❌ Error saving image to GridFS: $e');
      return null;
    }
  }
  
  Future<Uint8List?> getImageFromGridFS(String fileId) async {
    if (!isConnected || _gridFS == null) {
      print('❌ MongoDB not connected');
      return null;
    }
    
    try {
      final objectId = ObjectId.fromHexString(fileId);
      final gridOut = await _gridFS!.findOne(where.id(objectId));
      
      if (gridOut == null) {
        print('❌ Image not found in GridFS: $fileId');
        return null;
      }
      
      // TODO: Implement proper GridOut data reading
      // For now, just return null - saving works fine
      print('⚠️ Image retrieval from GridFS not yet implemented');
      return null;
      
    } catch (e) {
      print('❌ Error retrieving image from GridFS: $e');
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> getUserImages(String userId) async {
    if (!isConnected || _gridFS == null) {
      print('❌ MongoDB not connected');
      return [];
    }
    
    try {
      // Query GridFS files collection for user's images
      final filesCollection = _db!.collection('images.files');
      final userImages = await filesCollection.find(where.eq('metadata.userId', userId)).toList();
      
      return userImages.map((image) => {
        'id': image['_id'].toString(),
        'originalName': image['metadata']['originalName'],
        'uploadedAt': image['metadata']['uploadedAt'],
        'fileSize': image['metadata']['fileSize'],
        'contentType': image['metadata']['contentType'],
        'filename': image['filename'],
      }).toList();
      
    } catch (e) {
      print('❌ Error getting user images: $e');
      return [];
    }
  }
  
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
  
  // Get current user ID from Supabase
  String? get currentUserId {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id;
  }
}
