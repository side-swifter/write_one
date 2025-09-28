import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalDocument {
  final String id;
  final String title;
  final String extractedText;
  final double confidence;
  final String imagePath;
  final String source; // 'shutter' or 'gallery'
  final DateTime createdAt;
  final bool hasText;
  final int aiPercentage;

  LocalDocument({
    required this.id,
    required this.title,
    required this.extractedText,
    required this.confidence,
    required this.imagePath,
    required this.source,
    required this.createdAt,
    required this.hasText,
    required this.aiPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'extractedText': extractedText,
      'confidence': confidence,
      'imagePath': imagePath,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'hasText': hasText,
      'aiPercentage': aiPercentage,
    };
  }

  factory LocalDocument.fromJson(Map<String, dynamic> json) {
    return LocalDocument(
      id: json['id'],
      title: json['title'],
      extractedText: json['extractedText'],
      confidence: json['confidence'],
      imagePath: json['imagePath'],
      source: json['source'],
      createdAt: DateTime.parse(json['createdAt']),
      hasText: json['hasText'],
      aiPercentage: json['aiPercentage'],
    );
  }
}

class LocalStorageService {
  static const String _documentsKey = 'local_documents';
  static LocalStorageService? _instance;
  
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }
  
  LocalStorageService._();

  /// Save a document locally
  Future<String> saveDocument({
    required String title,
    required String extractedText,
    required double confidence,
    required String imagePath,
    required String source,
    required bool hasText,
    required int aiPercentage,
  }) async {
    try {
      // Generate unique ID
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Copy image to app documents directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final originalFile = File(imagePath);
      final fileName = '${id}_${path.basename(imagePath)}';
      final newImagePath = path.join(imagesDir.path, fileName);
      
      // Copy the image file
      if (await originalFile.exists()) {
        await originalFile.copy(newImagePath);
      }
      
      // Create document
      final document = LocalDocument(
        id: id,
        title: title,
        extractedText: extractedText,
        confidence: confidence,
        imagePath: newImagePath,
        source: source,
        createdAt: DateTime.now(),
        hasText: hasText,
        aiPercentage: aiPercentage,
      );
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final documents = await getDocuments();
      documents.add(document);
      
      final documentsJson = documents.map((doc) => doc.toJson()).toList();
      await prefs.setString(_documentsKey, jsonEncode(documentsJson));
      
      print('✅ Document saved locally with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error saving document locally: $e');
      rethrow;
    }
  }

  /// Get all documents
  Future<List<LocalDocument>> getDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsString = prefs.getString(_documentsKey);
      
      if (documentsString == null) {
        return [];
      }
      
      final documentsJson = jsonDecode(documentsString) as List;
      return documentsJson
          .map((json) => LocalDocument.fromJson(json))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
    } catch (e) {
      print('❌ Error loading documents: $e');
      return [];
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String id) async {
    try {
      final documents = await getDocuments();
      final documentIndex = documents.indexWhere((doc) => doc.id == id);
      
      if (documentIndex == -1) {
        return false;
      }
      
      final document = documents[documentIndex];
      
      // Delete image file
      final imageFile = File(document.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      
      // Remove from list
      documents.removeAt(documentIndex);
      
      // Save updated list
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = documents.map((doc) => doc.toJson()).toList();
      await prefs.setString(_documentsKey, jsonEncode(documentsJson));
      
      print('✅ Document deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deleting document: $e');
      return false;
    }
  }

  /// Clear all documents
  Future<void> clearAllDocuments() async {
    try {
      final documents = await getDocuments();
      
      // Delete all image files
      for (final document in documents) {
        final imageFile = File(document.imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_documentsKey);
      
      print('✅ All documents cleared');
    } catch (e) {
      print('❌ Error clearing documents: $e');
    }
  }

  /// Get document by ID
  Future<LocalDocument?> getDocument(String id) async {
    try {
      final documents = await getDocuments();
      return documents.firstWhere(
        (doc) => doc.id == id,
        orElse: () => throw StateError('Document not found'),
      );
    } catch (e) {
      print('❌ Document not found: $id');
      return null;
    }
  }
}
