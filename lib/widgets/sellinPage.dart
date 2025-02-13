// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

/*
* This is selling page
* This takes  data from database
* mainName-> main grid name
* firstLName->First level name
* secondLName-> Second level name
* lan -> for filter options
* tabName-> to check is it for selling or purchase
* need to get current user details
* these are for the add items pages and buying page
 */

/*
TODO: Main Items
  // * To view the details
  // * To buy details
  * Notify the relavent user
  * Add images
TODO: Sub Items
  // * Filter items
  * Main Page paramters
      * background for this is ready
 */

import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/repository/db_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomSellingPage extends StatefulWidget {
  final String mainName, firstLName, secondLName, lan, tabName;
  final String mainNameE, firstLNameE, secondLNameE, tabNameE;

  const CustomSellingPage({
    super.key,
    required this.mainName,
    required this.firstLName,
    required this.secondLName,
    required this.lan,
    required this.tabName,
    required this.mainNameE,
    required this.firstLNameE,
    required this.secondLNameE,
    required this.tabNameE,
  });

  @override
  // ignore: no_logic_in_create_state
  State<CustomSellingPage> createState() => _CustomSellingPageState(
    mainName: mainName,
    firstLName: firstLName,
    secondLName: secondLName,
    lan: lan,
  );
}

class _CustomSellingPageState extends State<CustomSellingPage>
    with SingleTickerProviderStateMixin {
  final String mainName, firstLName, secondLName, lan;
  late Stream<QuerySnapshot> _stream;
  late AnimationController _fadeController;

  _CustomSellingPageState({
    required this.mainName,
    required this.firstLName,
    required this.secondLName,
    required this.lan,
  });

  @override
  void initState() {
    super.initState();
    _stream = listenForData();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context) {
    // showCustomBottomSheet(
    //   context,
    //   (selectedData) {
    //     // Handle the selected data from the bottom sheet
    //     print('Selected data received in parent: $selectedData');
    //     setState(() {
    //       final path = paths(
    //         widget.mainNameE,
    //         widget.firstLNameE,
    //         widget.secondLNameE,
    //         widget.tabNameE,
    //       );
    //       final query;
    //       if (selectedData['district'] != null && selectedData['dso'] != null) {
    //         query = path
    //             .where('district', isEqualTo: selectedData['district'])
    //             .where('dso', isEqualTo: selectedData['dso']);
    //         _stream = query.snapshots();
    //       } else if (selectedData['district'] == null &&
    //           selectedData['dso'] != null) {
    //         query = path.where('dso', isEqualTo: selectedData['dso']);
    //         _stream = query.snapshots();
    //       } else if (selectedData['district'] != null &&
    //           selectedData['dso'] == null) {
    //         query = path.where('district', isEqualTo: selectedData['district']);
    //         _stream = query.snapshots();
    //       } else {
    //         _stream = listenForData();
    //       }
    //     });
    //   },
    //   widget.secondLNameE,
    //   widget.firstLNameE,
    //   lan,
    // );
  }

  Stream<QuerySnapshot> listenForData() {
    final path = paths(
      widget.mainNameE,
      widget.firstLNameE,
      widget.secondLNameE,
      widget.tabNameE,
    );
    return path.snapshots();
  }

  Future<void> sendNotification(String sellerId, String message) async {
    DocumentSnapshot sellerDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(sellerId)
            .get();

    String? sellerToken = sellerDoc.get('fcmToken');
    const String serverKey = 'YOUR_SERVER_KEY';

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(<String, dynamic>{
        'notification': <String, dynamic>{
          'body': message,
          'title': 'New Purchase',
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
        },
        'to': sellerToken,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [_buildStreamBuilder(), _buildActionButtons()]),
    );
  }

  Widget _buildStreamBuilder() {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final data = snapshot.data!.docs;
        return _buildListView(data);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.accent),
              SizedBox(height: 16),
              Text(
                "Error: $error",
                style: TextStyle(color: AppColors.text),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<QueryDocumentSnapshot> data) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100, top: 8, left: 8, right: 8),
      itemCount: data.length,
      itemBuilder: (context, index) => _buildListItem(data[index], index),
    );
  }

  Widget _buildListItem(QueryDocumentSnapshot doc, int index) {
    return FadeTransition(
      opacity: _fadeController,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondary.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            //    Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder:
            //         (context) => ItemViewPage(
            //           district: doc["district"],
            //           dso: doc["dso"],
            //           mainNameE: mainName,
            //           secondNameE: widget.secondLNameE,
            //           imagelink1:
            //               (doc["image1URL"] == null)
            //                   ? ''
            //                   : doc["image1URL"],
            //           imagelink2:
            //               (doc["image2URL"] == null)
            //                   ? ''
            //                   : doc["image2URL"],
            //           arces: doc["acres"],
            //           perches: doc["perches"],
            //           price: doc["price"],
            //           date:
            //               (doc["date"] == null)
            //                   ? ''
            //                   : doc["date"],
            //           details: doc["details"],
            //           userId: 'uid',
            //           ownerId: 'ownerid',
            //           rates: '5',
            //           fcmToken:
            //               (doc["fcmToken"] == null)
            //                   ? ''
            //                   : doc["fcmToken"],
            //         ),
            //   ),
            // )
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemHeader(doc),
                SizedBox(height: 12),
                _buildItemContent(doc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader(QueryDocumentSnapshot doc) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          "${doc["district"]}-${doc["dso"]}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildItemContent(QueryDocumentSnapshot doc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItemImage(doc),
        SizedBox(width: 16),
        Expanded(child: _buildItemDetails(doc)),
      ],
    );
  }

  Widget _buildItemImage(QueryDocumentSnapshot doc) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          doc["image1URL"] != 'image1Url'
              ? Image.network(doc["image1URL"], fit: BoxFit.cover)
              : Image(
                image: AssetImage("assets/img/lands.webp"),
                fit: BoxFit.cover,
              ),
    );
  }

  Widget _buildItemDetails(QueryDocumentSnapshot doc) {
    if (mainName == 'Lands') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${AppLocalizations.of(context)!.acres}: ${doc["acres"]} - ${AppLocalizations.of(context)!.perches}: ${doc["perches"]}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "${AppLocalizations.of(context)!.rs} ${doc["price"]}",
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Other content types
    final Map<String, String> contentTypes = {
      'harvest': "Harvest Related Parameters",
      'seeds': "Plants and Seeds Parameters",
      'animals': "Animal Control Parameters",
      'productions': "Productions Parameters",
      'labour': "Labour Name",
      'vehicles': "Vehicles parameters",
      'transport': "Transport Parameters",
      'machineries': "Machineries Parameters",
      'agriEquipmet': "Agri Equipments",
      'agrochems': "Agro Chems Parameters",
    };

    String content = contentTypes[mainName] ?? "";
    if (content.isEmpty) return Container();

    return Text(content, style: TextStyle(fontSize: 16, color: AppColors.text));
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 25,
      right: 15,
      left: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.search,
            label: "Search",
            onPressed: () => _showBottomSheet(context),
          ),
          _buildActionButton(
            icon: Icons.add,
            label: "Enter",
            onPressed: () {
              //   Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder:
              //         (context) => ItemsAddPage(
              //           mainName: mainName,
              //           firstLName: firstLName,
              //           secondLName: secondLName,
              //           lan: lan,
              //           tabName: widget.tabName,
              //           mainNameE: widget.mainNameE,
              //           firstLNameE: widget.firstLNameE,
              //           secondLNameE: widget.secondLNameE,
              //           tabNameE: widget.tabNameE,
              //         ),
              //   ),
              // )
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
