import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String USERS_COLLECTION = 'users';
  static const String PROFILE_IMAGES_PATH = 'profile_images';

  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get user profile from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String userId,
  ) async {
    try {
      return await _firestore.collection(USERS_COLLECTION).doc(userId).get();
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Get current user profile
  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserProfile() async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    return getUserProfile(currentUserId!);
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(USERS_COLLECTION).doc(userId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    return updateUserProfile(currentUserId!, data);
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
        '$PROFILE_IMAGES_PATH/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete old profile image
  Future<void> deleteOldProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('$PROFILE_IMAGES_PATH/$userId/');
      final items = await ref.listAll();

      for (var file in items.items) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting old profile image: $e');
      // Don't throw, just log the error
    }
  }

  /// Search users by name
  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection(USERS_COLLECTION)
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThan: query + 'z')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get user statistics (listings, rating, reviews)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      final data = profile.data() ?? {};

      return {
        'totalListings': data['totalListings'] ?? 0,
        'avgRating': data['avgRating'] ?? 0.0,
        'reviewCount': data['reviewCount'] ?? 0,
        'isActive': data['isActive'] ?? true,
      };
    } catch (e) {
      print('Error fetching user stats: $e');
      return {
        'totalListings': 0,
        'avgRating': 0.0,
        'reviewCount': 0,
        'isActive': false,
      };
    }
  }

  /// Update user rating and review count
  Future<void> updateUserRating(
    String userId,
    double newRating,
    int newReviewCount,
  ) async {
    try {
      await updateUserProfile(userId, {
        'avgRating': newRating,
        'reviewCount': newReviewCount,
      });
    } catch (e) {
      print('Error updating user rating: $e');
      throw e;
    }
  }

  /// Increment user listings count
  Future<void> incrementListingsCount(String userId) async {
    try {
      await _firestore.collection(USERS_COLLECTION).doc(userId).update({
        'totalListings': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing listings count: $e');
      throw e;
    }
  }

  /// Decrement user listings count
  Future<void> decrementListingsCount(String userId) async {
    try {
      await _firestore.collection(USERS_COLLECTION).doc(userId).update({
        'totalListings': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error decrementing listings count: $e');
      throw e;
    }
  }

  /// Verify if profile is complete
  bool isProfileComplete(Map<String, dynamic>? userData) {
    if (userData == null) return false;

    final requiredFields = [
      'firstName',
      'lastName',
      'mobileNumber',
      'address',
      'nicNumber',
      'district',
      'dso',
    ];

    return requiredFields.every(
      (field) =>
          userData[field] != null && userData[field].toString().isNotEmpty,
    );
  }

  /// Get user display name
  String getUserDisplayName(Map<String, dynamic>? userData) {
    if (userData == null) return 'Unknown User';
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';
    return '$firstName $lastName'.trim();
  }

  /// Deactivate user account
  Future<void> deactivateUserAccount(String userId) async {
    try {
      await updateUserProfile(userId, {
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deactivating user account: $e');
      throw e;
    }
  }

  /// Reactivate user account
  Future<void> reactivateUserAccount(String userId) async {
    try {
      await updateUserProfile(userId, {'isActive': true});
    } catch (e) {
      print('Error reactivating user account: $e');
      throw e;
    }
  }

  /// Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection(USERS_COLLECTION)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  /// Get list of all users (admin function - use with caution)
  Future<List<Map<String, dynamic>>> getAllUsers({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection(USERS_COLLECTION)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'uid': doc.id})
          .toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  /// Stream user profile updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(
    String userId,
  ) {
    return _firestore.collection(USERS_COLLECTION).doc(userId).snapshots();
  }

  /// Export user data (GDPR)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final profile = await getUserProfile(userId);

      return {
        'profile': profile.data(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error exporting user data: $e');
      throw e;
    }
  }
}
