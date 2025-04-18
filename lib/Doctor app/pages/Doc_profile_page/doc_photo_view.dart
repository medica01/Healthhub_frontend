import 'package:flutter/material.dart';

import '../../../main.dart';

class doc_view extends StatefulWidget {
  final dynamic doc_photo;

  const doc_view({super.key, required this.doc_photo});

  @override
  State<doc_view> createState() => _doc_viewState();
}

class _doc_viewState extends State<doc_view> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Image.network(
              "http://$ip:8000${widget.doc_photo}"),
        ),
      ),
    );
  }
}
