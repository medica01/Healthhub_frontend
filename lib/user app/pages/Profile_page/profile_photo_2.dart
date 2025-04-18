import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

class pati_view extends StatefulWidget {
  final dynamic pati_views;
  const pati_view({super.key,required this.pati_views});

  @override
  State<pati_view> createState() => _pati_viewState();
}

class _pati_viewState extends State<pati_view> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Image.network(
              "http://$ip:8000${widget.pati_views}"),
        ),
      ),
    );
  }
}
