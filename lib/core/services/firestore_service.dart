import 'package:aswenna/data/repository/firestore_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add item to Firestore
  Future<DocumentReference?> addItem({
    required List<String> pathSegments,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      // Add timestamp and user ID
      final enhancedData = {
        ...itemData,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      };

      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      return await _firestore.collection(collectionPath).add(enhancedData);
    } catch (e) {
      print('Error adding item: $e');
      throw e;
    }
  }

  // Get items with query options
  Future<QuerySnapshot> getItems(
    List<String> pathSegments, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      Query query = _firestore.collection(collectionPath);

      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      // Apply ordering if provided
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit if provided
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error getting items: $e');
      throw e;
    }
  }

  // Update an item
  Future<void> updateItem({
    required List<String> pathSegments,
    required String documentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);

      // Add update timestamp
      final enhancedUpdates = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .update(enhancedUpdates);
    } catch (e) {
      print('Error updating item: $e');
      throw e;
    }
  }

  // Delete an item
  Future<void> deleteItem({
    required List<String> pathSegments,
    required String documentId,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      print('Error deleting item: $e');
      throw e;
    }
  }

  // Upload image and get URL
  Future<String> uploadImage(File file, String path) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.hashCode}.webp';
      final Reference ref = _storage.ref().child('images/$path/$fileName');
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/webp'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  // Get items with pagination
  Future<QuerySnapshot> getItemsPaginated(
    List<String> pathSegments, {
    DocumentSnapshot? lastDocument,
    int pageSize = 10,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      Query query = _firestore.collection(collectionPath);

      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      // Apply ordering if provided
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        // Default ordering by creation date
        query = query.orderBy('createdAt', descending: true);
      }

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(pageSize);

      return await query.get();
    } catch (e) {
      print('Error getting paginated items: $e');
      throw e;
    }
  }

  // Get item by ID
  Future<DocumentSnapshot?> getItemById({
    required List<String> pathSegments,
    required String documentId,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      return await _firestore.collection(collectionPath).doc(documentId).get();
    } catch (e) {
      print('Error getting item by ID: $e');
      throw e;
    }
  }

  // Get user items
  Future<QuerySnapshot> getUserItems(
    List<String> pathSegments, {
    String? userId,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      final String userIdToUse = userId ?? currentUserId ?? '';

      if (userIdToUse.isEmpty) {
        throw Exception('User ID is required');
      }

      Query query = _firestore
          .collection(collectionPath)
          .where('userId', isEqualTo: userIdToUse);

      // Apply ordering if provided
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        // Default ordering by creation date
        query = query.orderBy('createdAt', descending: true);
      }

      return await query.get();
    } catch (e) {
      print('Error getting user items: $e');
      throw e;
    }
  }
}
