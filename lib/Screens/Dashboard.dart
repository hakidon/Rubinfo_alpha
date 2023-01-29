import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttercharts/Screens/chartTest.dart';
import 'package:fluttercharts/Screens/prediction_page.dart';
import 'package:fluttercharts/Screens/display_record.dart';
import 'package:fluttercharts/Screens/record_weight.dart';
import 'package:fluttercharts/charts/LineChartDashboard.dart';
import 'package:intl/intl.dart';
import 'package:fluttercharts/charts/LineChartSample.dart';

class Dashboard extends StatefulWidget {
  const Dashboard();

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final user = FirebaseAuth.instance.currentUser;
  final ref = FirebaseDatabase.instance.ref();
  bool _dataLoaded = false;
  double _gradient;
  var _latest_price = <String, dynamic>{}; //latest price
  String _price_today = "";


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

  String dropdownYr = '2023';
  String dropdownMth = '1';

  // var years = ["2010","2011", "2012, "2013", "2014","2015", "2016", "2017", "2018", "2019","2020","2021","2022"];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as ' + user.email),
            Container(
              child: LineChartDashboard(_latest_price),
            ),

            //Sign out
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.green,
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            //Set price threshold
            MaterialButton(
              child: Text(
                'Set Price Threshold',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.green,
              onPressed: () {
                showSetThreshold();
              },
            ),

            //Record Weight page
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordWeight()),
                );
              },
              child: Text(
                'Record Weight',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.green,
            ),

            // Display record page
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayRecord()),
                );
              },
              child: Text(
                'Display Record',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.green,
            ),

            // Display prediction page
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Prediction()),
                );
              },
              child: Text(
                'Display Prediction',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  double priceThreshold = 0.0;

  void showSetThreshold() async {
    final selectedPriceThreshold = await showDialog<double>(
      context: context,
      builder: (context) => SetThreshold(initialPriceThreshold: priceThreshold),
    );

    if (selectedPriceThreshold != null) {
      setState(() {
        priceThreshold = selectedPriceThreshold;
      });
    }
  }
}

class SetThreshold extends StatefulWidget {
  final double initialPriceThreshold;

  const SetThreshold({Key key, this.initialPriceThreshold}) : super(key: key);

  @override
  _SetThresholdState createState() => _SetThresholdState();
}

class _SetThresholdState extends State<SetThreshold> {
  double priceThreshold;

  @override
  void initState() {
    super.initState();
    priceThreshold = widget.initialPriceThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Set Price Threshold"),
      content: Container(
        height: 170,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0"),
                Slider(
                    min: 0.0,
                    max: 1000.0,
                    divisions: 1000,
                    label: "$priceThreshold",
                    value: priceThreshold,
                    onChanged: (double values) {
                      setState(() {
                        priceThreshold = values;
                      });
                    }),
                Text("1000"),
              ],
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Price (RM)'),
              keyboardType: TextInputType.number,
              onChanged: (String values) {
                setState(() {
                  priceThreshold = double.parse(values);
                });
              },
            ),
            SizedBox(height: 20),
            Text(
                "You will be notified when the rubber price reaches your threshold."),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          child: Text("Save"),
          onPressed: () {
            Navigator.pop(context, priceThreshold);

            final user = FirebaseAuth.instance.currentUser;
            saveThreshold(user.uid);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  void saveThreshold(String email) {
    double threshold = priceThreshold;
    final databaseReference = FirebaseDatabase.instance.ref();
    var now = DateTime.now();
    var dateOnly = DateFormat("yyyy-MM-dd").format(now);
    databaseReference.child("Threshold").child(email).push().set({
      'threshold': threshold,
      'timestamp': dateOnly,
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Price threshold set!"),
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

