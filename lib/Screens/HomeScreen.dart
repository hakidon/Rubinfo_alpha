import 'dart:collection';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttercharts/charts/LineChartSample.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ref = FirebaseDatabase.instance.ref();
  bool _dataLoaded = false;
  var _latest_price = <String, dynamic>{};
  var _predictions = <String, dynamic>{};
  String _price_today = "";
  String _prediction_today = "";

  LinkedHashMap<String, dynamic> listToMap(List<dynamic> list) {
    var map = LinkedHashMap<String, dynamic>();
    for (var i = 0; i < list.length; i++) {
      map["item_$i"] = list[i];
    }
    return map;
  }

  Map<String, dynamic> sortMap(Map<String, dynamic> map) {
    var listOfChildren = map.entries.toList();
    listOfChildren.sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(listOfChildren);
  }

  String getFormattedDate() {
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(now);
  }

  DateTime getDateTime(String dateString) {
    var formatter = DateFormat('dd-MM-yyyy');
    return formatter.parse(dateString);
  }

  List<int> getDateComponents(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;
    return [day, month, year];
  }

  Future<void> fetch_fb() async {
    // List<Object> predictions = [];

    var today = getDateComponents(DateTime.now());
    var snapshot = await ref
        .child('Prices/' + today[2].toString() + '/' + today[1].toString())
        .get();
    if (snapshot.exists) {
      setState(() {
        _latest_price = jsonDecode(jsonEncode(snapshot.value));
        _latest_price = sortMap(_latest_price);
        _price_today =
            _latest_price[_latest_price.keys.toList()[_latest_price.length - 1]]
                    ['Bulk Latex']
                .toStringAsFixed(2);
      });

      // for (String key in latest_price.keys) {
      //   print(getDateComponents(
      //       DateFormat.d().parse(latest_price[key]['Date']))[0]);
      // }
    }

    snapshot = await ref.child('Predictions/').get();
    if (snapshot.exists) {
      setState(() {
        List<Object> prediction = [];
        prediction = snapshot.value;
        _predictions = listToMap(prediction);
        // double aa = double.parse(sourceString);
        _prediction_today = _predictions[_predictions.keys.toList()[1]]['Price']
            .toStringAsFixed(2);
      });
    }
    setState(() {
      _dataLoaded = true;
    });
    // setSpot(latest_price, predictions);
  }

  @override
  void initState() {
    super.initState();
    fetch_fb();
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: Text(
            'Rubinfo alpha',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Predictions',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: LineChartSample(_latest_price, _predictions),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.blue,
                    width: 5.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Bulk latex price today: \RM$_price_today',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.blue,
                    width: 5.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Next prediction: \RM$_prediction_today',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
