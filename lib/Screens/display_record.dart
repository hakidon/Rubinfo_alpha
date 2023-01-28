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
        title: Text('Display record'),
      ),
    );
  }
}
