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
          //* Rent/Lease
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
          switch (secondName) {
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
            case 'Suwadel':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('Suwadel')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Kurulu Thuda':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('kurulu_thuda')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Pachchaperumal':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('Pachchaperumal')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Rathdel':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('Rathdel')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Kalu Heenati':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('kalu_heenati')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Rathu Heenati':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('rathu_heenati')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Sudu Heenati':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('sudu_heenati')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Goda Heenati':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('goda_heenati')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Masuran':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('masuran')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Kahawanu':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('kahawanu')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Madathawalu':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('madathawalu')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Ma wee':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('ma_wee')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Pokkali':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('pokkali')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Hatada wee':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('hatada_wee')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Dik wee':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('dik_wee')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');

            case 'Gonnabaru':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('gonnabaru')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');

            case 'Dahanala':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('dahanala')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');

            case 'Basmathi':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('basmathi')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
            case 'Other':
              return FirebaseFirestore.instance
                  .collection('harvest')
                  .doc('Paddy')
                  .collection('other')
                  .doc(tabName == 'selling' ? 'selling' : 'buying')
                  .collection('data');
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
