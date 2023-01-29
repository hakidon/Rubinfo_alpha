import 'dart:collection';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttercharts/charts/LineChartSample.dart';
import 'package:intl/intl.dart';

class Prediction extends StatefulWidget {
  @override
  _PredictionState createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  final ref = FirebaseDatabase.instance.ref();
  bool _dataLoaded = false;
  double _gradient;
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
        _price_today = (_latest_price[_latest_price.keys
                    .toList()[_latest_price.length - 1]]['Bulk Latex'] /
                100)
            .toStringAsFixed(2);
      });
    }

    snapshot = await ref.child('Predictions/').get();
    if (snapshot.exists) {
      List<Object> prediction = [];
      prediction = snapshot.value;
      _predictions = listToMap(prediction);

      double gradient = 0;
      int prevDay = _predictions[_predictions.keys.toList()[0]]['Day'];
      double prevPrice = _predictions[_predictions.keys.toList()[0]]['Price'];

      for (int i = 1; i < _predictions.length; i++) {
        int currDay = _predictions[_predictions.keys.toList()[i]]['Day'];
        double currPrice = double.parse(
            _predictions[_predictions.keys.toList()[i]]['Price']
                .toStringAsFixed(2));
        gradient += (currPrice - prevPrice) / (currDay - prevDay);
        prevDay = currDay;
        prevPrice = currPrice;
      }

      // Divide by number of data points to get average gradient
      gradient /= _predictions.length - 1;

      setState(() {
        // double aa = double.parse(sourceString);
        _prediction_today =
            (_predictions[_predictions.keys.toList()[1]]['Price'] / 100)
                .toStringAsFixed(2);
        _gradient = gradient;
      });
    }
    setState(() {
      _dataLoaded = true;
    });
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
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: Text(
            'Rubber Price Predictions',
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
              padding: const EdgeInsets.all(30.0),
              child: LineChartSample(_latest_price, _predictions),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(3, 3),
                  )
                ],
              ),
              child: Text(
                'Bulk latex price today: \RM$_price_today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(3, 3),
                  )
                ],
              ),
              child: Text(
                'Next prediction: \RM$_prediction_today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 35.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: _gradient > 0.1
                        ? Colors.green
                        : _gradient < -0.1
                            ? Colors.red
                            : Color.lerp(Colors.yellow, Colors.blue, 0.5),
                    width: 5.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Predicted market trend: ${_gradient > 0.1 ? 'Bullish' : _gradient < -0.1 ? 'Bearish' : 'Stagnant'}',
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
