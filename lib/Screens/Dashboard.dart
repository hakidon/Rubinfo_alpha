import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttercharts/Screens/prediction_page.dart';
import 'package:fluttercharts/Screens/display_record.dart';
import 'package:fluttercharts/Screens/record_weight.dart';
import 'package:intl/intl.dart';
import 'package:fluttercharts/charts/LineChartSample.dart';

class Dashboard extends StatefulWidget {
  const Dashboard();

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as ' + user.email),

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
