// import 'dart:collection';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fluttercharts/charts/LineChartDashboard.dart';
// import 'package:intl/intl.dart';
//
// class ChartTest extends StatefulWidget {
//
//   @override
//   _ChartTestState createState() => _ChartTestState();
// }
//
// class _ChartTestState extends State<ChartTest> {
//
//   final user = FirebaseAuth.instance.currentUser;
//   final ref = FirebaseDatabase.instance.ref();
//   bool _dataLoaded = false;
//   double _gradient;
//   var _latest_price = <String, dynamic>{}; //latest price
//   String _price_today = "";
//
//
//   LinkedHashMap<String, dynamic> listToMap(List<dynamic> list) {
//     var map = LinkedHashMap<String, dynamic>();
//     for (var i = 0; i < list.length; i++) {
//       map["item_$i"] = list[i];
//     }
//     return map;
//   }
//
//   Map<String, dynamic> sortMap(Map<String, dynamic> map) {
//     var listOfChildren = map.entries.toList();
//     listOfChildren.sort((a, b) => a.key.compareTo(b.key));
//     return Map.fromEntries(listOfChildren);
//   }
//
//   String getFormattedDate() {
//     var now = DateTime.now();
//     var formatter = DateFormat('dd-MM-yyyy');
//     return formatter.format(now);
//   }
//
//   DateTime getDateTime(String dateString) {
//     var formatter = DateFormat('dd-MM-yyyy');
//     return formatter.parse(dateString);
//   }
//
//   List<int> getDateComponents(DateTime date) {
//     int day = date.day;
//     int month = date.month;
//     int year = date.year;
//     return [day, month, year];
//   }
//
//   Future<void> fetch_fb() async {
//     // List<Object> predictions = [];
//
//     var today = getDateComponents(DateTime.now());
//     var snapshot = await ref
//         .child('Prices/' + today[2].toString() + '/' + today[1].toString())
//         .get();
//     if (snapshot.exists) {
//       setState(() {
//         _latest_price = jsonDecode(jsonEncode(snapshot.value));
//         _latest_price = sortMap(_latest_price);
//         _price_today =
//             _latest_price[_latest_price.keys.toList()[_latest_price.length - 1]]
//             ['Bulk Latex']
//                 .toStringAsFixed(2);
//       });
//     }
//     setState(() {
//       _dataLoaded = true;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetch_fb();
//   }
//
//   String dropdownYr = '2023';
//   String dropdownMth = '1';
//
//  // var years = ["2010","2011", "2012, "2013", "2014","2015", "2016", "2017", "2018", "2019","2020","2021","2022"];
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_dataLoaded) {
//       return Center(child: CircularProgressIndicator(),);
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Chart Test'),
//         ),
//         body: LineChartDashboard(_latest_price),
//         children: [
//           DropdownButton(items: items, onChanged: onChanged)
//         ]
//
//       );
//     }
//   }
// }
