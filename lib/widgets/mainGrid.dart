// // ignore_for_file: file_names

// /*
// * This is the main grid. This from home page to first step
//   *! ~1~
//  */

// import 'package:flutter/material.dart';

// import '../Lists and Coonectors/common_data.dart';
// import '../Lists and Coonectors/Converters/connectors.dart';
// import 'secondGrid.dart';

// class CustomeListView extends StatefulWidget {
//   // title-> main page name
//   // listname -> first level list name
//   // lan -> language
//   // userAppBar -> to remove or add the appBar
//   final String listname, title, lan, titleE;
//   final bool useAppBar;
//   const CustomeListView({
//     super.key,
//     required this.listname,
//     required this.useAppBar,
//     required this.title,
//     required this.lan,
//     required this.titleE,
//   });

//   @override
//   State<CustomeListView> createState() =>
//       _CustomeListViewState(listname: listname, lan: lan);
// }

// class _CustomeListViewState extends State<CustomeListView> {
//   final String listname, lan;
//   //get the list from list name
//   late List<String> list;
//   late List<String> enList;
//   _CustomeListViewState({required this.listname, required this.lan}) {
//     list = mainGridConnector(listname, lan);
//     enList = mainGridConnector(listname, 'en');
//     print('EnList $enList');
//   }
//   @override
//   Widget build(BuildContext context) {
//     // print(enList);
//     return Scaffold(
//       backgroundColor: AppColors.dark,
//       appBar:
//           widget.useAppBar
//               ? AppBar(
//                 title: Text(
//                   widget.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.0,
//                   ),
//                 ),
//                 iconTheme: const IconThemeData(
//                   color: Colors.white, // Change this to your desired color
//                 ),
//                 centerTitle: true,
//                 elevation: 1.0,
//                 backgroundColor: Colors.transparent,
//               )
//               : null,
//       body:
//           (list.length != Null)
//               ? ListView.builder(
//                 itemCount: list.length,
//                 itemBuilder: (BuildContext context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.only(left: 10.0, right: 3.0),
//                     child: GestureDetector(
//                       child: Card(
//                         color: Colors.white,
//                         child: SizedBox(
//                           height: 60.0,
//                           // padding: EdgeInsets.only(left: 20.0),
//                           child: Row(
//                             children: [
//                               Transform(
//                                 alignment: Alignment.centerLeft,
//                                 transform: Matrix4.translationValues(
//                                   -10.0,
//                                   0.0,
//                                   0.0,
//                                 ),
//                                 child: Container(
//                                   width: 40.0,
//                                   height: 30.0,
//                                   decoration: const BoxDecoration(
//                                     color: AppColors.darklow,
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       (index + 1).toString(),
//                                       style: const TextStyle(
//                                         color: AppColors.textColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 list[index],
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: AppColors.darklow,
//                                   fontSize: 15.0,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       onTap:
//                           () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) => CustomeSubListView(
//                                     listname: enList[index],
//                                     title: list[index],
//                                     lan: lan,
//                                     mainName: widget.title,
//                                     mainNameE: widget.titleE,
//                                     firstLNameE: enList[index],
//                                   ),
//                             ),
//                           ),
//                     ),
//                   );
//                 },
//               )
//               : CustomSellingPage(
//                 mainName: widget.title,
//                 firstLName: '',
//                 secondLName: '',
//                 lan: lan,
//                 tabName: '',
//                 mainNameE: widget.titleE,
//                 firstLNameE: '',
//                 secondLNameE: '',
//                 tabNameE: '',
//               ),
//     );
//   }
// }
