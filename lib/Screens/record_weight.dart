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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Weight'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
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
                    _insertWeight(user.email);
                  } else {
                    print('User is not logged in');
                  }
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _insertWeight(String email) {
    double weight = double.parse(_weightController.text);
    final databaseReference = FirebaseDatabase.instance.ref();
    var now = DateTime.now();
    var dateOnly = DateFormat("yyyy-MM-dd").format(now);
    databaseReference
        .child("Weight")
        .child(email.replaceAll(".", ","))
        .push()
        .set({
      'weight': weight,
      'timestamp': dateOnly,
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
