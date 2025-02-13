import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> databasePaths(
  String mainName,
  String firstName,
  String secondName,
  String tabName,
) {
  switch (mainName) {
    case 'land':
      final landsRef = FirebaseFirestore.instance.collection('lands');
      if (firstName == 'Mud Lands') {
        if (secondName == 'Rent') {
          if (tabName == 'selling') {
            return landsRef
                .doc('mudlands')
                .collection('rent')
                .doc('lease_sale')
                .collection('data')
                .snapshots();
          } else {
            return landsRef
                .doc('mudlands')
                .collection('rent')
                .doc('lease_purchase')
                .collection('data')
                .snapshots();
          }
        } else {
          if (tabName == 'selling') {
            return landsRef
                .doc('mudlands')
                .collection('Sell')
                .doc('lease_sale')
                .collection('data')
                .snapshots();
          } else {
            return landsRef
                .doc('mudlands')
                .collection('Sell')
                .doc('lease_purchase')
                .collection('data')
                .snapshots();
          }
        }
      } else {
        // Handle other firstNames within 'land' collection
        return Stream.empty(); // Or return appropriate default stream
      }
    default:
      return Stream.empty();
  }
}

CollectionReference paths(
  String mainName,
  String firstName,
  String secondName,
  String tabName,
) {
  switch (mainName) {
    case 'land':
      if (firstName == 'Mud Lands') {
        if (secondName == 'Sell') {
          if (tabName == 'selling') {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('mudlands')
                .collection('sell')
                .doc('lease_sale')
                .collection('data');
          } else {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('mudlands')
                .collection('sell')
                .doc('lease_purchase')
                .collection('data');
          }
        } else {
          if (tabName == 'selling') {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('mudlands')
                .collection('rent')
                .doc('lease_sale')
                .collection('data');
          } else {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('mudlands')
                .collection('rent')
                .doc('lease_purchase')
                .collection('data');
          }
        }
      } else {
        if (secondName == 'Sell') {
          if (tabName == 'selling') {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('Lands')
                .collection('sell')
                .doc('lease_sale')
                .collection('data');
          } else {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('Lands')
                .collection('sell')
                .doc('lease_purchase')
                .collection('data');
          }
        } else {
          if (tabName == 'selling') {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('Lands')
                .collection('rent')
                .doc('lease_sale')
                .collection('data');
          } else {
            return FirebaseFirestore.instance
                .collection('lands')
                .doc('Lands')
                .collection('rent')
                .doc('lease_purchase')
                .collection('data');
          }
        }
      }
    case 'harvest':
      switch (firstName) {
        case 'Paddy':
          switch (firstName) {
            case 'Improved':
              if (tabName == 'selling') {
                FirebaseFirestore.instance
                    .collection('harvest')
                    .doc('Paddy')
                    .collection('Improved')
                    .doc('selling')
                    .collection('data');
              } else {
                FirebaseFirestore.instance
                    .collection('harvest')
                    .doc('Paddy')
                    .collection('Improved')
                    .doc('buying')
                    .collection('data');
              }
          }
        case 'cerealCrops':
        case 'coconut':
        case 'tea':
        case 'rubber':
        case 'vegetables':
        case 'fruits':
        case 'potato':
        case 'greenleaves':
        case 'flowers':
        case 'cashew':
        case 'forestry':
        case 'herbles':
        default:
      }
  }
  return FirebaseFirestore.instance.collection('error');
}
