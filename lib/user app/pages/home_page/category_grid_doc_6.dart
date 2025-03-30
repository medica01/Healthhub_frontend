import 'package:flutter/material.dart';

class cate_doc extends StatefulWidget {
  const cate_doc({super.key});

  @override
  State<cate_doc> createState() => _cate_docState();
}

class _cate_docState extends State<cate_doc> {
  final List<String> items =
      List<String>.generate(20, (index) => 'Item $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.blue,
              child: Center(
                child: Text(
                  items[index],
                  style: const TextStyle(color: Colors.white,),
                ),
              ),
            );
          },
        ));
  }
}
