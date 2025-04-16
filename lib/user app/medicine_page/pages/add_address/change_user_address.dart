import 'package:flutter/material.dart';

class change_user_address extends StatefulWidget {
  const change_user_address({super.key});

  @override
  State<change_user_address> createState() => _change_user_addressState();
}

class _change_user_addressState extends State<change_user_address> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Change Address",style: TextStyle(color: Colors.blueAccent),),
      ),
    );
  }
}
