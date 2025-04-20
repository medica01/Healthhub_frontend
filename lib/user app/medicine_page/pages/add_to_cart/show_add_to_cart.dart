import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:health_hub/main.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../Backend_information/medicine_app_backend/add_to_cart_backend.dart';
import '../Med_home_page/about_specific_product.dart';

class show_to_cart extends StatefulWidget {
  const show_to_cart({super.key});

  @override
  State<show_to_cart> createState() => _show_to_cartState();
}

class _show_to_cartState extends State<show_to_cart> {
  List<add_to_carts> show_add_to_cart_user = [];
  bool loading = false;
  DateTime now = DateTime.now();
  String formattedseven ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show_date();
    _get_user_add_to_cart();
  }

  void show_date(){
    DateTime seven= now.add(Duration(days: 7));
    formattedseven = DateFormat('EEEE').format(seven);
  }

  Future<void> _get_user_add_to_cart() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_add_to_cart/$phone_number/"));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          show_add_to_cart_user =
              jsonResponse.map((data) => add_to_carts.fromJson(data)).toList();
          loading = true;
        });
      } else {
        Text("the err is get show add to cart user");
        loading = true;
      }
    } catch (e) {
      Text("${e.toString()}");
    }
  }

  Future<void> _delete_your_cart_item(int cart) async {
    String phone_number = "";

    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.delete(Uri.parse(
          "http://$ip:8000/medicine_pur/delete_your_cart/$phone_number/$cart/"));
      if (response.statusCode == 204) {
        _get_user_add_to_cart();
      } else {
        print("err in the backend");
      }
    } catch (e) {
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Your Cart",
            style: TextStyle(color: Colors.blueAccent),
          ),
          centerTitle: true,
        ),
        body: loading
            ? (show_add_to_cart_user.isEmpty
                ? Center(
                    child: Text(
                      "No Item Selected",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: show_add_to_cart_user.length,
                        itemBuilder: (context, index) {
                          var carts = show_add_to_cart_user[index];
                          return carts.productNumber != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28.0, right: 28, bottom: 15),
                                  child: AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                  horizontalOffset: 500.0,
                                  child: FadeInAnimation(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  specific_product(
                                                    product_number:
                                                    "${carts.productNumber}",
                                                  )));
                                    },
                                    child: Card(
                                      elevation: 5,
                                      clipBehavior: Clip.hardEdge,
                                      shadowColor: Colors.grey,
                                      child: Padding(
                                        padding:  EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 140,
                                          // height: 160,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 18.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 150,
                                                      height: 90,
                                                      child: Image(
                                                          image: NetworkImage(

                                                              // scale: 3,
                                                              "http://$ip:8000${carts.productImage}")),
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.all(10.0),
                                                      child: Text("delivery time: $formattedseven"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${carts.productName}",overflow: TextOverflow.ellipsis,),
                                                    Text(
                                                      "${carts.cureDisases}",
                                                      // maxLines: 2, // Limit to 2 lines
                                                      overflow: TextOverflow.ellipsis, // Show "..." for overflow
                                                    ),
                                                    Text(
                                                        "${carts.quantity} ml bottle",overflow: TextOverflow.ellipsis,),
                                                    Text("${carts.price} Rs",overflow: TextOverflow.ellipsis,),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.only(top: 10.0),
                                                      child: OutlinedButton(
                                                        onPressed: () {
                                                          _delete_your_cart_item(
                                                              carts.productNumber!);
                                                        },
                                                        style:
                                                        OutlinedButton.styleFrom(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .blueAccent,
                                                                width: 1)),
                                                        child: Text(
                                                          "delete",
                                                          style: TextStyle(
                                                              color:
                                                              Colors.blueAccent),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),)))

                                )
                              : SizedBox.shrink();
                        }),
                    Container(
                      height: 100,
                    )
                  ],
                ))
            : Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
          height: 100,))
      ),
    );
  }
}
