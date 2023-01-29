import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DisplayRecord extends StatefulWidget {
  const DisplayRecord();

  @override
  State<DisplayRecord> createState() => _DisplayRecordState();
}

class _DisplayRecordState extends State<DisplayRecord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Record'),
      ),
      body: StreamBuilder<dynamic>(
        stream: FirebaseDatabase.instance
            .ref()
            .child("Weight")
            .child(FirebaseAuth.instance.currentUser.uid)
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<dynamic, dynamic> values = snapshot.data.snapshot.value;
            List<Weight> weights = [];
            if (values != null) {
              values.forEach((key, value) {
                Weight weight = Weight.fromJson(value);
                weight.key = key;
                weights.add(weight);
              });
            }
            return ListView.builder(
              itemCount: weights.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Weight: ${weights[index].weight} kg'),
                  subtitle: Text('Date: ${weights[index].timestamp}'),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class Weight {
  int weight;
  String timestamp;
  String key;

  Weight({this.weight, this.timestamp});

  factory Weight.fromJson(Map<dynamic, dynamic> json) {
    return Weight(
      weight: json['weight'],
      timestamp: json['timestamp'] as String,
    );
  }
}
