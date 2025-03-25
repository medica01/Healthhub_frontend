import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/medicine_app_backend/medicine_purchase_backend.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Backend_information/medicine_app_backend/patient_address_backend.dart';
import '../add_address/add_pati_address.dart';
import 'Place_order.dart';
import 'order_successfully.dart';

class specific_product extends StatefulWidget {
  final dynamic product_number;

  specific_product({super.key, required this.product_number});

  @override
  State<specific_product> createState() => _specific_productState();
}

class _specific_productState extends State<specific_product> {
  medicine_purchase? specific_product;
  bool isloading = false;
  String errs = "";
  bool isChecked = false;
  String phone_number = "";
  patient_address? patients_address;
  int a = 1;
  int amount = 0;
  int totalau = 0;
  DateTime now = DateTime.now();
  String formattedseven="";



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show_date();
    _specific_products();
    _get_patients_address();
  }
  void addition() {
    if (specific_product == null) return; // Prevent null access
    setState(() {
      if (a < 10) {
        a++;
        totalau = totalau + amount;
      }
    });
  }

  void minus() {
    if (specific_product == null) return; // Prevent null access
    setState(() {
      if (a > 1) {
        a--;
        totalau = totalau - amount;
      }
    });
  }

  void show_date(){
    DateTime seven= now.add(Duration(days: 7));
    formattedseven = DateFormat('EEEE d MMM yyyy').format(seven);
  }

  void show_quantity_price()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("quantity", a);
    pref.setInt("total_price", totalau);
    pref.setString("delivery_date", formattedseven);

  }



  Future<void> _get_patients_address() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_specific_user_specific_address/$phone_number/1/"));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          patients_address = patient_address.fromJson(jsonResponse);
          isChecked = true;
        });
      } else {
        print("error in the program");
        isChecked = true;
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  Future<void> _specific_products() async {
    String product_number = "";
    product_number = widget.product_number;
    try {
      final response = await http.get(
          Uri.parse(
              "http://$ip:8000/medicine_pur/get_specific_product/$product_number/"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          specific_product = medicine_purchase.fromJson(jsonResponse);
          isloading = true;
          amount = specific_product!.price as int;
          totalau= specific_product!.price as int;
        });
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("product_number", specific_product!.productNumber as int);
      } else {
        isloading = true;
        errs = "err in the code";
        Text("$errs");
      }
    } catch (e) {
      isloading = true;
      errs = e.toString();
      print("$errs");
    }
  }

  Future<void> _create_add_to_carts() async {
    String phone_number = "";
    int product_number = specific_product!.productNumber as int;
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.post(
          Uri.parse("http://$ip:8000/medicine_pur/create_add_to_cart/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "pry_phone_number": "${phone_number}",
            "product_number": product_number
          }));
      if (response.statusCode == 201) {
        showModalBottomSheet(
            context: context,
            // isScrollControlled: true,
            builder: (context) {
              return bottom_add_to_show(
                  product_img: "${specific_product!.productImage}",
                  product_name: "${specific_product!.productName}");
            });
      } else {
        errs = "the error to added to cart";
        Text("${errs}");
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isloading == true
            ? Text(
                "${specific_product!.productName}",
                style: TextStyle(color: Colors.blueAccent),
              )
            : SizedBox(),
      ),
      body: isloading == true
          ? ListView(
              children: [
                Center(
                  child: Container(
                    width: 150,
                    height: 300,
                    child: Image(
                        image: NetworkImage(
                            "http://$ip:8000${specific_product!.productImage}")),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${specific_product!.productName}"),
                      Text("${specific_product!.aboutProduct}"),
                      Text("${specific_product!.cureDisases}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "₹ ${specific_product!.price}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 40),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 40,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                              ),
                              child: Center(
                                child: Text(
                                  "-63%",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5.0, top: 15),
                            child: Container(
                              height: 90,
                              width: 190,
                              // color:Colors.red,
                              child: Column(
                                children: [
                                  Text("Quantity"),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: OutlinedButton(
                                              onPressed: () {
                                                minus();
                                              },
                                              child: Text("-"))),
                                      Flexible(
                                        child: Container(
                                            width: 65,
                                            child: OutlinedButton(
                                                onPressed: () {},
                                                child: Text("$a"))),
                                      ),
                                      Container(
                                          width: 60,
                                          child: OutlinedButton(
                                              onPressed: () {
                                                addition();
                                              },
                                              child: Text("+"))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        "inclusive of all taxes",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 18.0, left: 5),
                  child: Text(
                    "FREE delivery $formattedseven, \nOrder within 19hrs 56 mins.",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 18.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_sharp,
                        color: Colors.blue,
                      ),
                      patients_address== null ||
                      patients_address!.fullName == null ||
                              patients_address!.townCity == null ||
                              patients_address!.pincode == null
                          ? Text("No address")
                          : Text(
                              " Deliver to ${patients_address!.fullName} - ${patients_address!.townCity} ${patients_address!.pincode}"),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 8.0, bottom: 8, right: 5, left: 5),
                    child: Container(
                      width: 420,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            width: 115,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 0.3),
                                // color: Colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(FontAwesomeIcons.cashRegister),
                                Text(
                                  "Lowest Price",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 115,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.money),
                                Text(
                                  "Cash on Delivery",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 115,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(FontAwesomeIcons.boxOpen),
                                Text(
                                  "Non Returnable",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child:
                      // kIsWeb !=true
                      // ?Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Center(
                      //     child: Column(
                      //       children: [
                      //         GestureDetector(
                      //           onTap: () {
                      //             patients_address == null||
                      //                     patients_address!.fullName == null ||
                      //                     patients_address!.areaBuildingName == null ||
                      //                     patients_address!.flatHouseName == null ||
                      //                     patients_address!.landmark == null ||
                      //                     patients_address!.pincode == null ||
                      //                     patients_address!.pryPhoneNumber == null ||
                      //                     patients_address!.secPhoneNumber == null ||
                      //                     patients_address!.townCity == null ||
                      //                     patients_address!.stateName == null
                      //                 ? Navigator.push(
                      //                     context,
                      //                     MaterialPageRoute(
                      //                         builder: (context) =>
                      //                             add_pati_address()))
                      //                 : Navigator.push(
                      //                     context,
                      //                     MaterialPageRoute(
                      //                         builder: (context) => place_order()));
                      //           },
                      //           child: Container(
                      //             height: 50,
                      //             width: MediaQuery.of(context).size.width * 0.52,
                      //             decoration: BoxDecoration(
                      //               color: Colors.blueAccent,
                      //               borderRadius: BorderRadius.circular(40),
                      //             ),
                      //             child:
                      //             Center(
                      //               child: Text(
                      //                 "Order",
                      //                 style: TextStyle(
                      //                     color: Colors.white, fontSize: 16),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: OutlinedButton(
                      //               style: OutlinedButton.styleFrom(
                      //                   fixedSize: Size(270, 50),
                      //                   animationDuration: Duration(seconds: 2),
                      //                   side: BorderSide(
                      //                       color: Colors.blueAccent, width: 2)),
                      //               onPressed: () {
                      //                 _create_add_to_carts();
                      //                 // Navigator.push(context, MaterialPageRoute(builder: (context)=>order_success()));
                      //               },
                      //               child: Text(
                      //                 "Add to cart",
                      //                 style: TextStyle(color: Colors.blueAccent),
                      //               )),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ):
                      Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 350,
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 50,
                            width: 170,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.blue, width: 1),
                                    shape: RoundedRectangleBorder()),
                                onPressed: () {
                                  _create_add_to_carts();
                                },
                                child: Text(
                                  "Add to cart",
                                  style: TextStyle(color: Colors.blue),
                                )),
                          ),
                          Container(
                            height: 50,
                            width: 170,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.blue, width: 1),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder()),
                                onPressed: () {
                                  show_quantity_price();
                                  patients_address == null ||
                                          patients_address!.fullName == null ||
                                          patients_address!.areaBuildingName ==
                                              null ||
                                          patients_address!.flatHouseName ==
                                              null ||
                                          patients_address!.landmark == null ||
                                          patients_address!.pincode == null ||
                                          patients_address!.pryPhoneNumber ==
                                              null ||
                                          patients_address!.secPhoneNumber ==
                                              null ||
                                          patients_address!.townCity == null ||
                                          patients_address!.stateName == null
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  add_pati_address(
                                                  )))
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  place_order(
                                                  )));
                                },
                                child: Text(
                                  "Buy Now",
                                  style: TextStyle(color: Colors.white),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                )
              ],
            )
          : Center(child: Container(child: CircularProgressIndicator())),
    );
  }
}

class bottom_add_to_show extends StatefulWidget {
  final dynamic product_img;
  final dynamic product_name;

  bottom_add_to_show(
      {super.key, required this.product_img, required this.product_name});

  @override
  State<bottom_add_to_show> createState() => _bottom_add_to_showState();
}

class _bottom_add_to_showState extends State<bottom_add_to_show> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        AppBar(
          backgroundColor: Colors.white,
          leading: Text(""),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close))
          ],
        ),
        Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white,
              width: 150,
              height: 150,
              child: Image(
                  image: NetworkImage("http://$ip:8000${widget.product_img}")),
            ),
            Text("${widget.product_name}"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Added to Cart",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ]),
    );
  }
}
