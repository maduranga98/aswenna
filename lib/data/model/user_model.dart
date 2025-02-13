class UserModel {
  final String name;
  final String address;
  final String id;
  final String mob1;
  final String? mob2;
  final String district;
  final String dso;
  final String fcmToken;
  final bool isRegistered;
  final bool isLoggedOut;
  final String language;
  final String docId;

  UserModel({
    required this.name,
    required this.address,
    required this.id,
    required this.mob1,
    this.mob2,
    required this.district,
    required this.dso,
    required this.fcmToken,
    this.isRegistered = true,
    this.isLoggedOut = false,
    required this.language,
    required this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'id': id,
      'mob1': mob1,
      'mob2': mob2,
      'district': district,
      'dso': dso,
      'fcmToken': fcmToken,
      'isRegistered': isRegistered,
      'isLoggedOut': isLoggedOut,
      'language': language,
      'docId': docId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      id: map['id'] ?? '',
      mob1: map['mob1'] ?? '',
      mob2: map['mob2'],
      district: map['district'] ?? '',
      dso: map['dso'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      isRegistered: map['isRegistered'] ?? true,
      isLoggedOut: map['isLoggedOut'] ?? false,
      language: map['language'] ?? '',
      docId: map['docId'] ?? '',
    );
  }
}
