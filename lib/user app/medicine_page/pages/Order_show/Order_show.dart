import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../Backend_information/medicine_app_backend/medicine_order_details_backend.dart';
import '../../../pages/Profile_page/profile_page.dart';
import '../Med_home_page/about_specific_product.dart';

class show_order_placed extends StatefulWidget {
  const show_order_placed({super.key});

  @override
  State<show_order_placed> createState() => _medicine_home_pageState();
}

class _medicine_home_pageState extends State<show_order_placed> {
  List<order_placed_details> order_placed_user_details = [];
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_order_placed_user_detials();
  }

  Future<void> _get_order_placed_user_detials() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_order_placed_details/$phone_number/"));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          order_placed_user_details = jsonResponse
              .map((data) => order_placed_details.fromJson(data))
              .toList();
          loading = true;
        });
      } else {
        loading = true;
        print("err is occured");
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text(
              "Your Order",
              style: TextStyle(color: Colors.blueAccent),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search,
                    color: Colors.blueAccent,
                  ))
            ],
          ),
          body:loading ==true
          ?ListView(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: order_placed_user_details.length,
                  itemBuilder: (context, index) {
                  var order_detials= order_placed_user_details[index];
                  return Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>profile_page()));
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>specific_product(
                                        product_number : "${order_detials.productNumber}"
                                    )));
                                  },
                                  child: Container(
                                    child: Image(
                                        image: NetworkImage(
                                            scale: 3,
                                            "http://$ip:8000${order_detials.productImage}")),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("${order_detials.productName}"),
                                    ),
                                    Text("Delivery 12 march",style: TextStyle(color: Colors.grey),)
                                  ],
                                ),
                                 Divider(
                                  color: Colors.red,
                                  thickness: 1,
                                  indent: 25,
                                  endIndent: 35,
                                ),
                                Icon(Icons.arrow_forward_ios,color: Colors.black,)
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  );
                  }),
              Container(
                height: 100,
              )
            ],
          ):Center(child: CircularProgressIndicator(),),
      ),
    );
  }
}
