import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttercharts/Screens/prediction_page.dart';
import 'package:fluttercharts/Screens/display_record.dart';
import 'package:fluttercharts/Screens/record_weight.dart';

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
                'Display prediction',
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
}
