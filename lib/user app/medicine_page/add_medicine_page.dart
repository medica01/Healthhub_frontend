import 'package:flutter/material.dart';

class add_medincine extends StatefulWidget {
  const add_medincine({super.key});

  @override
  State<add_medincine> createState() => _add_medincineState();
}

class _add_medincineState extends State<add_medincine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Medicine page",style: TextStyle(color: Colors.blueAccent),),
      ),
      body: ListView(
        children: [

        ],
      ),
    );
  }
}
