import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNumber;
  final String? alternativeMobile;
  final String? address;
  final String? nicNumber;
  final String? district;
  final String? dso;
  final String? profileImageUrl;
  final String? userType; // 'farmer', 'buyer', 'both'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int? totalListings;
  final double? avgRating;
  final int? reviewCount;

  UserProfile({
    required this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.alternativeMobile,
    this.address,
    this.nicNumber,
    this.district,
    this.dso,
    this.profileImageUrl,
    this.userType,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.totalListings,
    this.avgRating,
    this.reviewCount,
  });

  /// Get full name
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNumber': mobileNumber,
      'alternativeMobile': alternativeMobile,
      'address': address,
      'nicNumber': nicNumber,
      'district': district,
      'dso': dso,
      'profileImageUrl': profileImageUrl,
      'userType': userType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'totalListings': totalListings ?? 0,
      'avgRating': avgRating ?? 0.0,
      'reviewCount': reviewCount ?? 0,
    };
  }

  /// Create UserProfile from JSON (Firestore)
  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      email: map['email'] as String?,
      mobileNumber: map['mobileNumber'] as String?,
      alternativeMobile: map['alternativeMobile'] as String?,
      address: map['address'] as String?,
      nicNumber: map['nicNumber'] as String?,
      district: map['district'] as String?,
      dso: map['dso'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      userType: map['userType'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] as bool? ?? true,
      totalListings: map['totalListings'] as int? ?? 0,
      avgRating: (map['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
    );
  }

  /// Create a copy with modifications
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    String? alternativeMobile,
    String? address,
    String? nicNumber,
    String? district,
    String? dso,
    String? profileImageUrl,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? totalListings,
    double? avgRating,
    int? reviewCount,
  }) {
    return UserProfile(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      alternativeMobile: alternativeMobile ?? this.alternativeMobile,
      address: address ?? this.address,
      nicNumber: nicNumber ?? this.nicNumber,
      district: district ?? this.district,
      dso: dso ?? this.dso,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      totalListings: totalListings ?? this.totalListings,
      avgRating: avgRating ?? this.avgRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
