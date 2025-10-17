import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Single collection for all items
  static const String ITEMS_COLLECTION = 'items';

  String? get currentUserId => _auth.currentUser?.uid;

  /// Add item to Firestore (single collection, path stored in data)
  Future<DocumentReference?> addItem({
    required List<String> pathSegments,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User must be authenticated');
      }

      final enhancedData = {
        ...itemData,
        'userId': currentUserId,
        'pathSegments': pathSegments,
        'collectionPath': pathSegments.join('/'),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deleted': false,
      };

      return await _firestore.collection(ITEMS_COLLECTION).add(enhancedData);
    } catch (e) {
      print('Error adding item: $e');
      throw e;
    }
  }

  /// Get all items from a specific path
  Future<QuerySnapshot> getItems(
    List<String> pathSegments, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(ITEMS_COLLECTION);

      query = query.where('pathSegments', isEqualTo: pathSegments);
      query = query.where('deleted', isEqualTo: false);

      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      print('Error getting items: $e');
      throw e;
    }
  }

  /// Get items with pagination
  Future<QuerySnapshot> getItemsPaginated(
    List<String> pathSegments, {
    DocumentSnapshot? lastDocument,
    int pageSize = 10,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      Query query = _firestore.collection(ITEMS_COLLECTION);

      query = query.where('pathSegments', isEqualTo: pathSegments);
      query = query.where('deleted', isEqualTo: false);

      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      query = query.orderBy(orderBy ?? 'createdAt', descending: descending);

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

  /// Get item by ID
  Future<DocumentSnapshot?> getItemById({required String documentId}) async {
    try {
      return await _firestore
          .collection(ITEMS_COLLECTION)
          .doc(documentId)
          .get();
    } catch (e) {
      print('Error getting item by ID: $e');
      throw e;
    }
  }

  /// Get ALL user items across ALL paths
  Future<List<Map<String, dynamic>>> getUserItems({
    String? userId,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    try {
      final userIdToUse = userId ?? currentUserId;
      if (userIdToUse == null || userIdToUse.isEmpty) {
        throw Exception('User ID is required');
      }

      Query query = _firestore.collection(ITEMS_COLLECTION);

      query = query.where('userId', isEqualTo: userIdToUse);
      query = query.where('deleted', isEqualTo: false);

      query = query.orderBy(orderBy ?? 'createdAt', descending: descending);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final items = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      return items;
    } catch (e) {
      print('Error getting user items: $e');
      throw e;
    }
  }

  /// Get user items from a specific path
  Future<QuerySnapshot> getUserItemsFromPath(
    List<String> pathSegments, {
    String? userId,
    String? orderBy,
    bool descending = true,
  }) async {
    try {
      final String userIdToUse = userId ?? currentUserId ?? '';

      if (userIdToUse.isEmpty) {
        throw Exception('User ID is required');
      }

      Query query = _firestore.collection(ITEMS_COLLECTION);

      query = query.where('userId', isEqualTo: userIdToUse);
      query = query.where('pathSegments', isEqualTo: pathSegments);
      query = query.where('deleted', isEqualTo: false);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      return await query.get();
    } catch (e) {
      print('Error getting user items from path: $e');
      throw e;
    }
  }

  /// Update item
  Future<void> updateItem({
    required String documentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection(ITEMS_COLLECTION).doc(documentId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating item: $e');
      throw e;
    }
  }

  /// Delete item (soft delete)
  Future<void> deleteItem({required String documentId}) async {
    try {
      await _firestore.collection(ITEMS_COLLECTION).doc(documentId).update({
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting item: $e');
      throw e;
    }
  }

  /// Upload image
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
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  /// Stream for real-time updates
  Stream<QuerySnapshot> streamItems(
    List<String> pathSegments, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query query = _firestore.collection(ITEMS_COLLECTION);

      query = query.where('pathSegments', isEqualTo: pathSegments);
      query = query.where('deleted', isEqualTo: false);

      if (filters != null && filters.isNotEmpty) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      return query.snapshots();
    } catch (e) {
      print('Error streaming items: $e');
      throw e;
    }
  }

  /// Search user items
  Future<List<Map<String, dynamic>>> searchUserItems({
    required String searchTerm,
    String? userId,
  }) async {
    try {
      final userIdToUse = userId ?? currentUserId;
      if (userIdToUse == null) throw Exception('User ID required');

      final allItems = await getUserItems(userId: userIdToUse);

      final searchLower = searchTerm.toLowerCase();
      final results = allItems.where((item) {
        final title = item['title']?.toString().toLowerCase() ?? '';
        final description = item['description']?.toString().toLowerCase() ?? '';

        return title.contains(searchLower) || description.contains(searchLower);
      }).toList();

      return results;
    } catch (e) {
      print('Error searching: $e');
      throw e;
    }
  }

  /// Search items by path
  Future<List<Map<String, dynamic>>> searchItemsByPath({
    required List<String> pathSegments,
    required String searchTerm,
  }) async {
    try {
      final snapshot = await getItems(
        pathSegments,
        orderBy: 'createdAt',
        descending: true,
      );

      final searchLower = searchTerm.toLowerCase();
      final results = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .where((item) {
            final title = item['title']?.toString().toLowerCase() ?? '';
            final description =
                item['description']?.toString().toLowerCase() ?? '';

            return title.contains(searchLower) ||
                description.contains(searchLower);
          })
          .toList();

      return results;
    } catch (e) {
      print('Error searching items by path: $e');
      throw e;
    }
  }
}
