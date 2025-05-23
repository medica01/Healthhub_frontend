import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../../../../Backend_information/medicine_app_backend/medicine_purchase_backend.dart';
import '../../../../Backend_information/medicine_app_backend/patient_address_backend.dart';
import '../../../../Notification_services.dart';
import '../../../../main.dart';
import '../add_address/add_another_address.dart';
import '../add_address/change_user_address.dart';
import 'about_specific_product.dart';
import 'order_successfully.dart';

class place_order extends StatefulWidget {

  place_order({super.key,});

  @override
  State<place_order> createState() => _place_orderState();
}

class _place_orderState extends State<place_order> {
  bool isChecked = false;
  medicine_purchase? specific_products;
  String phone_number = "";
  patient_address? patients_address;
  int a = 0;
  String selectedPaymentMethod = "Cash on delivery";
  int quantity = 0;
  int total_price = 0;
  String delivery_date = "";
  DateTime now = DateTime.now();
  String formattedseven = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show_date();
    show_quantity_price();
    get_patients_address();
    _get_product_number();
  }

  void show_date() {
    DateTime seven = now.add(Duration(days: 7));
    formattedseven = DateFormat('EEEE').format(seven);
  }

  void show_quantity_price() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      quantity = perf.getInt("quantity") ?? 0;
      total_price = perf.getInt("total_price") ?? 0;
      delivery_date = perf.getString("delivery_date") ?? "";
    });
  }


  void _onCashOnDelivery() {
    setState(() {
      selectedPaymentMethod = "Cash on delivery";
    });
    print("Selected: Cash on delivery");
    // Your Cash on Delivery function here
  }

  void _onVisaPayment() {
    setState(() {
      selectedPaymentMethod = "VISA ....6766";
    });
    print("Selected: VISA ....6766");
    // Your VISA Payment function here
  }

  void _onGPay() {
    setState(() {
      selectedPaymentMethod = "G Pay";
    });
    print("Selected: G Pay");
    // Your GPay function here
  }

  Future<void> _create_order_details_patient() async {
    int address_id = 0;
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
      address_id = perf.getInt("address_id") ?? 1;
    });
    try {
      final response = await http.post(Uri.parse(
          "http://$ip:8000/medicine_pur/create_order_placed_details/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "pry_phone_number": "${phone_number}",
            "address_id": "${address_id}",
            "product_number": "${specific_products!.productNumber}",
            "purchase_quantity": "${quantity}",
            "purchase_total_price": "${total_price}",
            "purchase_pay_type": "${selectedPaymentMethod}",
            "order_date": "${delivery_date}"
          }));
      if (response.statusCode == 201) {
        _vibrate();
        NotificationService().showNotification(id: 0,
            title: "Health Hub",
            body: "${specific_products!
                .productName} Order Placed Successfully \nDelivered on ${delivery_date}");
        showBottomSheet(
            context: context, builder: (context) => order_success());
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  Future<void> _get_product_number() async {
    int product_number = 0;
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      product_number = (perf.getInt("product_number") ?? "") as int;
      print("${product_number}");
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_specific_product/$product_number/"));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          specific_products = medicine_purchase.fromJson(jsonResponse);
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

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> get_patients_address() async {
    // String phone_number ="";
    int address_id = 0;
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
      address_id = perf.getInt("address_id") ?? 1;
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_specific_user_specific_address/$phone_number/$address_id/"));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          patients_address = patient_address.fromJson(jsonResponse);
          isChecked = true;
        });
      }
      else {
        print("error in the program");
        isChecked = true;
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        centerTitle: true,
        title: Text(
          "Order",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
      body: isChecked
          ? Padding(
        padding: EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Address",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    patients_address!=null
                    ?ListTile(
                      title: Text(
                        "${patients_address!.fullName}",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Text(
                                    "${patients_address!
                                        .flatHouseName},\n${patients_address!
                                        .areaBuildingName},\n${patients_address!
                                        .townCity} ${patients_address!
                                        .pincode},\n${patients_address!
                                        .stateName},\n${patients_address!
                                        .secPhoneNumber}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return change_address(
                                              getpatiadd: get_patients_address);
                                        });
                                  },
                                  child: Text("change", style: TextStyle(
                                      color: Colors.blueAccent, fontSize: 20),))
                            ],
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => another_address()));
                              }, child: Text("add address", style: TextStyle(
                              color: Colors.blueAccent, fontSize: 20),))
                        ],
                      ),
                    ):SizedBox(),
                    Container(
                      width: 400,
                      height: 300,
                      // color: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "payment method",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          _buildPaymentOption(
                              "Cash on delivery", selectedPaymentMethod ==
                              "Cash on delivery", _onCashOnDelivery),
                          _buildPaymentOption(
                              "VISA ....6766", selectedPaymentMethod ==
                              "VISA ....6766", _onVisaPayment),
                          _buildPaymentOption("G Pay", selectedPaymentMethod ==
                              "G Pay", _onGPay),

                          SizedBox(height: 20),
                          Text("Arriving $delivery_date", style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    specific_products !=null
                    ?Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Container(
                        // width: 140,
                        // height: 160,
                        // color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 2.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    child: Image(
                                        image: NetworkImage(
                                          // scale: 3,
                                            "http://$ip:8000${specific_products!
                                                .productImage}")),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                        "delivery time: $formattedseven"),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${specific_products!.productName}",
                                    overflow: TextOverflow.ellipsis,),
                                  Text("${specific_products!.aboutProduct}",
                                    overflow: TextOverflow.ellipsis,),
                                  Text("${specific_products!.cureDisases}"),
                                  Text("₹ ${specific_products!.price}")
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ):SizedBox(),
                    Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Quantity"),
                                Text("${quantity}")
                              ],
                            ), Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total price"),
                                Text("₹ ${total_price}")
                              ],
                            ), Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Devlivery Cost"),
                                Text("- ₹ 0.00")
                              ],
                            ), Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Discount"),
                                Text("- ₹ 0.00")
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                              indent: 5,
                              endIndent: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                Text("₹ ${total_price}",style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 28.0),
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 70,
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.blueAccent, width: 2)),
                              onPressed: () {
                                _create_order_details_patient();
                              },
                              child: Text(
                                "Place the order",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
            )
          ],
        ),
      ) : Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
        height: 100,))
    );
  }
}

Widget _buildPaymentOption(String method, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: isSelected ? Colors.blue.shade100 : Colors.,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1)
      ),
      child: Row(
        children: [
          Expanded(child: Text(method, style: TextStyle(fontSize: 16))),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: Colors.blueAccent,
          ),
        ],
      ),
    ),
  );
}

class change_address extends StatefulWidget {
  final Function getpatiadd;

  change_address({super.key, required this.getpatiadd});

  @override
  State<change_address> createState() => _change_addressState();
}

class _change_addressState extends State<change_address> {
  List<patient_address> patients_address = [];
  bool isloading = false;
  String err = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_user_addresss();
  }

  Future<void> _get_user_addresss() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });

    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_specific_user_address/$phone_number/"));
      if (response.statusCode == 200) {
        List<dynamic>jsonResponse = jsonDecode(response.body);
        setState(() {
          patients_address =
              jsonResponse.map((data) => patient_address.fromJson(data))
                  .toList();
          isloading = true;
        });
      }
      else {
        err = "err in the program ${response.body}";
        print("$err");
      }
    } catch (e) {
      err = e.toString();
      print("$err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? SingleChildScrollView(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40))
        ),
        height: 500,
        child: Column(
          children: [
            AppBar(
              leading: Text(""),
              centerTitle: true,
              title: Text("Change Address", style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),),
              actions: [
                IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Icon(Icons.close))
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: patients_address.length,
                itemBuilder: (context, index) {
                  var user_add = patients_address[index];
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                          horizontalOffset: 500.0,
                          child: FadeInAnimation(
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    SharedPreferences pref = await SharedPreferences
                                        .getInstance();
                                    pref.setInt("address_id",
                                        user_add.sequenceNumber ?? 1);
                                    widget.getpatiadd();
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white54,
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                        Border.all(color:
                                        Colors.black, width: 1)),
                                    child: ListTile(
                                      title: Text("${user_add.fullName}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [

                                            Text(
                                                "${user_add
                                                    .flatHouseName},${user_add
                                                    .areaBuildingName},${user_add
                                                    .townCity}"),
                                            Text(
                                                "${user_add
                                                    .areaBuildingName},${user_add
                                                    .townCity}"),
                                            Text("${user_add.pincode}"),
                                            Text(
                                                "Phone number: ${user_add
                                                    .secPhoneNumber}")
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          )
                      )
                  );
                }
            )
          ],
        ),
      ),
    ) : Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
    height: 100,));
  }
}


