import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RecordWeight extends StatefulWidget {
  const RecordWeight();

  @override
  State<RecordWeight> createState() => _RecordWeightState();
}

class _RecordWeightState extends State<RecordWeight> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  double weight;
  double totalPrice = 0;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Weight'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) => setState(() {
                  weight = double.parse(value);
                  totalPrice = weight * double.parse(_price_today);
                }),
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    final user = _auth.currentUser;
                    if (user != null) {
                      _insertWeight(user.uid);
                    } else {
                      print('User is not logged in');
                    }
                  }
                },
                child: Text('Submit'),
              ),
              SizedBox(
                height: 30,
              ),
              // Price today container
              Container(
                child: Text("Price today : RM $_price_today"),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
              ),

              SizedBox(
                height: 30,
              ),
              // Total Price
              Container(
                child: Text("Total Price: RM $totalPrice"),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertWeight(String email) {
    double weight = double.parse(_weightController.text);
    final databaseReference = FirebaseDatabase.instance.ref();
    var now = DateTime.now();
    var dateOnly = DateFormat("yyyy-MM-dd").format(now);
    databaseReference.child("Weight").child(email).push().set({
      'weight': weight,
      'timestamp': dateOnly,
      'totalPrice': totalPrice,
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Weight recorded successfully"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
