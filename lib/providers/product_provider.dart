import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aswenna/core/services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Current products being displayed
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> userProducts = [];

  // Loading and error states
  bool isLoading = false;
  bool isLoadingUserProducts = false;
  String? errorMessage;

  // Pagination
  DocumentSnapshot? lastDocument;
  bool hasMoreProducts = true;

  /// Load products from a specific path (for browsing)
  /// Example: pathSegments = ['harvest', 'Paddy', 'Improved', 'selling']
  Future<void> loadProductsFromPath(
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

      products = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading products: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load paginated products from path
  Future<void> loadProductsPagedFromPath(
    List<String> pathSegments, {
    int pageSize = 10,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = true,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      lastDocument = null;
      products = [];
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

      final newProducts = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      products.addAll(newProducts);

      if (newProducts.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        hasMoreProducts = newProducts.length == pageSize;
      } else {
        hasMoreProducts = false;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading products: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load ALL user products (across all paths/categories)
  Future<void> loadAllUserProducts({
    String? orderBy,
    bool descending = true,
  }) async {
    isLoadingUserProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      userProducts = await _firestoreService.getUserItems(
        orderBy: orderBy,
        descending: descending,
      );

      isLoadingUserProducts = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading your products: $e';
      isLoadingUserProducts = false;
      notifyListeners();
    }
  }

  /// Load user products from a specific path
  Future<void> loadUserProductsFromPath(
    List<String> pathSegments, {
    String? orderBy,
    bool descending = true,
  }) async {
    isLoadingUserProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getUserItemsFromPath(
        pathSegments,
        orderBy: orderBy,
        descending: descending,
      );

      userProducts = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .toList();

      isLoadingUserProducts = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error loading your products: $e';
      isLoadingUserProducts = false;
      notifyListeners();
    }
  }

  /// Add product (use this from your add product page)
  Future<String?> addProduct({
    required List<String> pathSegments,
    required Map<String, dynamic> productData,
  }) async {
    try {
      final docRef = await _firestoreService.addItem(
        pathSegments: pathSegments,
        itemData: productData,
      );

      if (docRef != null) {
        // Refresh user products
        await loadAllUserProducts();
        return docRef.id;
      }
      return null;
    } catch (e) {
      errorMessage = 'Error adding product: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update product
  Future<bool> updateProduct({
    required String docId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestoreService.updateItem(documentId: docId, updates: updates);

      // Refresh
      await loadAllUserProducts();
      return true;
    } catch (e) {
      errorMessage = 'Error updating product: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct({required String docId}) async {
    try {
      await _firestoreService.deleteItem(documentId: docId);

      // Refresh
      await loadAllUserProducts();
      return true;
    } catch (e) {
      errorMessage = 'Error deleting product: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search user products
  Future<void> searchUserProducts(String searchTerm) async {
    isLoadingUserProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      userProducts = await _firestoreService.searchUserItems(
        searchTerm: searchTerm,
      );

      isLoadingUserProducts = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error searching products: $e';
      isLoadingUserProducts = false;
      notifyListeners();
    }
  }

  /// Search products by path
  Future<void> searchProductsByPath({
    required List<String> pathSegments,
    required String searchTerm,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Use client-side search since searchItemsByPath is not in new service
      final snapshot = await _firestoreService.getItems(
        pathSegments,
        orderBy: 'createdAt',
        descending: true,
      );

      final searchLower = searchTerm.toLowerCase();
      products = snapshot.docs
          .map(
            (doc) => {...doc.data() as Map<String, dynamic>, 'docId': doc.id},
          )
          .where((product) {
            final title = product['title']?.toString().toLowerCase() ?? '';
            final description =
                product['description']?.toString().toLowerCase() ?? '';

            return title.contains(searchLower) ||
                description.contains(searchLower);
          })
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error searching products: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Get single product by ID
  Future<Map<String, dynamic>?> getProductById({required String docId}) async {
    try {
      final doc = await _firestoreService.getItemById(documentId: docId);

      if (doc != null && doc.exists) {
        return {...doc.data() as Map<String, dynamic>, 'docId': doc.id};
      }
      return null;
    } catch (e) {
      errorMessage = 'Error getting product: $e';
      notifyListeners();
      return null;
    }
  }

  /// Stream products from path (for real-time updates)
  Stream<List<Map<String, dynamic>>> streamProductsFromPath(
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

  /// Get product count for a path
  Future<int> getProductCountForPath(List<String> pathSegments) async {
    try {
      final snapshot = await _firestoreService.getItems(pathSegments);
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting product count: $e');
      return 0;
    }
  }

  /// Get user product count
  Future<int> getUserProductCount() async {
    try {
      final items = await _firestoreService.getUserItems();
      return items.length;
    } catch (e) {
      print('Error getting user product count: $e');
      return 0;
    }
  }

  /// Clear state
  void clearState() {
    products = [];
    userProducts = [];
    lastDocument = null;
    hasMoreProducts = true;
    errorMessage = null;
    notifyListeners();
  }
}
