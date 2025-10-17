import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aswenna/core/services/firestore_service.dart';

class ItemsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Current items being displayed
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> userItems = [];

  // Loading and error states
  bool isLoading = false;
  bool isLoadingUserItems = false;
  String? errorMessage;

  // Pagination
  DocumentSnapshot? lastDocument;
  bool hasMoreItems = true;

  /// Load items from a specific path (for browsing)
  /// Example: pathSegments = ['harvest', 'Paddy', 'Improved', 'selling']
  Future<void> loadItemsFromPath(
    List<String> pathSegments, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getItems(
        pathSegments,
        filters: filters,
        orderBy: orderBy,
        descending: descending,
      );

      items = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading items: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load paginated items from path
  Future<void> loadItemsPagedFromPath(
    List<String> pathSegments, {
    int pageSize = 10,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = true,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      lastDocument = null;
      items = [];
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getItemsPaginated(
        pathSegments,
        lastDocument: lastDocument,
        pageSize: pageSize,
        filters: filters,
        orderBy: orderBy,
        descending: descending,
      );

      final newItems = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      items.addAll(newItems);

      if (newItems.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        hasMoreItems = newItems.length == pageSize;
      } else {
        hasMoreItems = false;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading items: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load ALL user items (across all paths)
  /// This gets all items for the current user
  Future<void> loadAllUserItems({
    String? orderBy,
    bool descending = true,
  }) async {
    isLoadingUserItems = true;
    errorMessage = null;
    notifyListeners();

    try {
      userItems = await _firestoreService.getUserItems(
        orderBy: orderBy,
        descending: descending,
      );

      isLoadingUserItems = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading your items: $e';
      isLoadingUserItems = false;
      notifyListeners();
    }
  }

  /// Load user items from a specific path
  Future<void> loadUserItemsFromPath(
    List<String> pathSegments, {
    String? orderBy,
    bool descending = true,
  }) async {
    isLoadingUserItems = true;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getUserItemsFromPath(
        pathSegments,
        orderBy: orderBy,
        descending: descending,
      );

      userItems = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      isLoadingUserItems = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading your items: $e';
      isLoadingUserItems = false;
      notifyListeners();
    }
  }

  /// Add item (use this from your add items page)
  Future<String?> addItem({
    required List<String> pathSegments,
    required Map<String, dynamic> itemData,
  }) async {
    try {
      final docRef = await _firestoreService.addItem(
        pathSegments: pathSegments,
        itemData: itemData,
      );

      if (docRef != null) {
        // Refresh user items
        await loadAllUserItems();
        return docRef.id;
      }
      return null;
    } catch (e) {
      errorMessage = 'Error adding item: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update item
  Future<bool> updateItem({
    required String docId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestoreService.updateItem(documentId: docId, updates: updates);

      // Refresh
      await loadAllUserItems();
      return true;
    } catch (e) {
      errorMessage = 'Error updating item: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete item
  Future<bool> deleteItem({required String docId}) async {
    try {
      await _firestoreService.deleteItem(documentId: docId);

      // Refresh
      await loadAllUserItems();
      return true;
    } catch (e) {
      errorMessage = 'Error deleting item: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search user items
  Future<void> searchUserItems(String searchTerm) async {
    isLoadingUserItems = true;
    errorMessage = null;
    notifyListeners();

    try {
      userItems = await _firestoreService.searchUserItems(
        searchTerm: searchTerm,
      );

      isLoadingUserItems = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error searching items: $e';
      isLoadingUserItems = false;
      notifyListeners();
    }
  }

  /// Search items by path
  Future<void> searchItemsByPath({
    required List<String> pathSegments,
    required String searchTerm,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      items = await _firestoreService.searchItemsByPath(
        pathSegments: pathSegments,
        searchTerm: searchTerm,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error searching items: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Get single item by ID
  Future<Map<String, dynamic>?> getItemById({required String docId}) async {
    try {
      final doc = await _firestoreService.getItemById(documentId: docId);

      if (doc != null && doc.exists) {
        return {...doc.data() as Map<String, dynamic>, 'docId': doc.id};
      }
      return null;
    } catch (e) {
      errorMessage = 'Error getting item: $e';
      notifyListeners();
      return null;
    }
  }

  /// Stream items from path (for real-time updates)
  Stream<List<Map<String, dynamic>>> streamItemsFromPath(
    List<String> pathSegments, {
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
  }) {
    return _firestoreService
        .streamItems(
          pathSegments,
          filters: filters,
          orderBy: orderBy,
          descending: descending,
        )
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'docId': doc.id,
                },
              )
              .toList(),
        );
  }

  /// Clear state
  void clearState() {
    items = [];
    userItems = [];
    lastDocument = null;
    hasMoreItems = true;
    errorMessage = null;
    notifyListeners();
  }
}
