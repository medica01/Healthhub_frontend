import 'package:flutter/material.dart';

class doc_home extends StatefulWidget {
  doc_home({super.key});

  @override
  State<doc_home> createState() => _doc_homeState();
}

class _doc_homeState extends State<doc_home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Doc_home_page(),
      ),
    );
  }
}

class Doc_home_page extends StatefulWidget {
  Doc_home_page({super.key});

  @override
  State<Doc_home_page> createState() => _Doc_home_pageState();
}

class _Doc_home_pageState extends State<Doc_home_page> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Doctor home page"),
    );
  }
}
