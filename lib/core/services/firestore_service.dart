import 'package:aswenna/data/repository/firestore_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addItem({
    required List<String> pathSegments,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      await _firestore.collection(collectionPath).add(itemData);
    } catch (e) {
      print('Error adding item: $e');
      throw e;
    }
  }

  Future<QuerySnapshot> getItems(List<String> pathSegments) async {
    try {
      print("Path segments:  $pathSegments");
      final String collectionPath = FirestorePaths.getItemPath(pathSegments);
      return await _firestore.collection(collectionPath).get();
    } catch (e) {
      print('Error getting items: $e');
      throw e;
    }
  }
}
