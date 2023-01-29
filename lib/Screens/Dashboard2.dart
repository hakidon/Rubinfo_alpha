import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttercharts/Screens/prediction_page.dart';
import 'package:fluttercharts/Screens/record_weight.dart';
import 'package:fluttercharts/charts/LineChartSample.dart';
import 'package:fluttercharts/charts/LineChartSample2.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'display_record.dart';

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

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final user = FirebaseAuth.instance.currentUser;
  final ref = FirebaseDatabase.instance.ref();

  var today = getDateComponents(DateTime.now());
  bool _dataLoaded = false;
  double _gradient;
  var _latest_price = <String, dynamic>{};
  var _predictions = <String, dynamic>{};
  String _price_today = "";
  String _prediction_today = "";
  double _user_threshold = 0;

  Future<void> fetch_fb() async {
    // List<Object> predictions = [];

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
            .toStringAsFixed(3);
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
                .toStringAsFixed(3);
        _gradient = gradient;
      });
    }
    setState(() {
      _dataLoaded = true;
    });
  }

  void setupNotification() {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init_settings = InitializationSettings(android: androidSetting);
    _localNotificationsPlugin.initialize(init_settings);

    //Listen latest price
    var ref_path = 'Prices/' + today[2].toString() + '/' + today[1].toString();

    DatabaseReference ref = FirebaseDatabase.instance.ref(ref_path);
    // Get the Stream
    Stream<DatabaseEvent> stream = ref.onValue;
    // Subscribe to the stream!
    stream.listen((DatabaseEvent event) {
      var _latest_update =
          sortMap(jsonDecode(jsonEncode(event.snapshot.value)));
      double price_today = double.parse((_latest_update[_latest_update.keys
                  .toList()[_latest_update.length - 1]]['Bulk Latex'] /
              100)
          .toStringAsFixed(3));
      if (price_today >= _user_threshold && _user_threshold != 0)
        showNotification(_user_threshold.toString(), price_today.toString());

      setState(() {
        _price_today = price_today.toString();
      });
    });

    //Listen threshold
    ref_path = 'Threshold/' + user.uid;

    DatabaseReference threshold_ref = FirebaseDatabase.instance.ref(ref_path);
    // Get the Stream
    Stream<DatabaseEvent> threshold_stream = threshold_ref.onValue;
    // Subscribe to the stream!
    threshold_stream.listen((DatabaseEvent event) {
      var threshold_update_json =
          (jsonDecode(jsonEncode(event.snapshot.value)));
      double threshold_update =
          double.parse(threshold_update_json['threshold'].toStringAsFixed(2));
      if (threshold_update <= double.parse(_price_today) &&
          double.parse(_price_today) != 0 &&
          threshold_update != 0)
        showNotification(threshold_update.toString(), _price_today.toString());

      setState(() {
        _user_threshold = threshold_update;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetch_fb();
    setupNotification();
  }

  showNotification(String noti_threshold, String price_today) {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "001",
      "Notify",
      importance: Importance.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      macOS: null,
      linux: null,
    );

    String title = 'Threshold price (RM${noti_threshold}) reached!';
    String noti_text = 'Today Price: RM${price_today}';

    _localNotificationsPlugin.show(01, title, noti_text, notificationDetails);
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
                'Latest Price: RM${_price_today}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: LineChartSampleDashboard(_latest_price),
            ),
            Center(
              child: Text(
                'Signed in as ${user.email}',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: 100.0,
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
                  MaterialButton(
                    minWidth: 200.0,
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
                  MaterialButton(
                    minWidth: 200.0,
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
                  MaterialButton(
                    minWidth: 200.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayRecord()),
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
                  MaterialButton(
                    minWidth: 200.0,
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
            )
          ],
        ),
      );
    }
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
                    max: 50.0,
                    divisions: 100,
                    label: "$priceThreshold",
                    value: priceThreshold,
                    onChanged: (double values) {
                      setState(() {
                        priceThreshold = values;
                      });
                    }),
                Text("50"),
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

  void saveThreshold(String uid) {
    double threshold = priceThreshold;
    final databaseReference = FirebaseDatabase.instance.ref();
    var now = DateTime.now();
    var dateOnly = DateFormat("yyyy-MM-dd").format(now);
    databaseReference.child("Threshold").child(uid).update({
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
