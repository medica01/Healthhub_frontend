import 'package:flutter/material.dart';

class medicine_home_page extends StatefulWidget {
  const medicine_home_page({super.key});

  @override
  State<medicine_home_page> createState() => _medicine_home_pageState();
}

class _medicine_home_pageState extends State<medicine_home_page> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            child: Text("medicine_home_page"),
          ),
        ),
      ),
    );
  }
}
