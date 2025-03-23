import 'package:flutter/material.dart';

import '../medical_home.dart';


class order_success extends StatefulWidget {
  const order_success({super.key});

  @override
  State<order_success> createState() => _book_successState();
}

class _book_successState extends State<order_success> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.blueAccent,
        body: GestureDetector(
          onTap: (){
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Medical_main_page()), (route)=>false);
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.check_circle_outline,color: Colors.white,size: 50,),
                ),
                Text("Order Successfully",style: TextStyle(color: Colors.white),)
              ],
            ),
          ),
        ),
    );
  }
}
