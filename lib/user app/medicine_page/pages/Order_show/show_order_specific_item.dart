import 'package:flutter/material.dart';

class show_spe_order_pro extends StatefulWidget {
  final dynamic product_number;

  show_spe_order_pro({super.key, required this.product_number});

  @override
  State<show_spe_order_pro> createState() => _show_spe_order_proState();
}

class _show_spe_order_proState extends State<show_spe_order_pro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        body: Center(child: Container(
          child: Text("${widget.product_number}"),
        )));
  }
}
