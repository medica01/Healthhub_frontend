import 'dart:io';

import 'package:flutter/material.dart';

class photos_vies extends StatefulWidget {
  final File photo_view;
  const photos_vies({super.key,required this.photo_view});

  @override
  State<photos_vies> createState() => _photos_viesState();
}

class _photos_viesState extends State<photos_vies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Image.file(
              widget.photo_view),
        ),
      ),
    );
  }
}
