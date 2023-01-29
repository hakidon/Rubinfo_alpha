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
        backgroundColor: Theme.of(context).primaryColor,
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
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: ListTile(
                      leading: SizedBox(
                        child: Image.asset('images/contract.png'),
                        width: 40,
                      ),
                      title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Weight: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '${weights[index].weight} kg, \n'),
                            TextSpan(
                                text: 'Total Price : ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                              text: 'RM${weights[index].totalPrice}',
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Date: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                              text: '${weights[index].timestamp}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
  double weight;
  double totalPrice;
  String timestamp;
  String key;

  Weight({this.weight, this.timestamp, this.totalPrice});

  factory Weight.fromJson(Map<dynamic, dynamic> json) {
    return Weight(
      weight: double.parse(json['weight'].toString()),
      timestamp: json['timestamp'] as String,
      totalPrice: double.parse(json['totalPrice'].toString()),
    );
  }
}
