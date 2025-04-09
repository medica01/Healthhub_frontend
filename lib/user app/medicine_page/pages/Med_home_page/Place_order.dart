import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../../../Backend_information/medicine_app_backend/medicine_purchase_backend.dart';
import '../../../../Backend_information/medicine_app_backend/patient_address_backend.dart';
import '../../../../Notification_services.dart';
import '../../../../main.dart';
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
  String phone_number ="";
  patient_address? patients_address;
  int a=0;
  String selectedPaymentMethod = "Cash on delivery";
  int quantity = 0;
  int total_price =0;
  String delivery_date="";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show_quantity_price();
    _get_patients_address();
    _get_product_number();
  }

  void show_quantity_price()async{
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      quantity=perf.getInt("quantity")??0;
      total_price=perf.getInt("total_price")??0;
      delivery_date=perf.getString("delivery_date")??"";
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

  Future<void> _create_order_details_patient() async{
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {

      phone_number = perf.getString("phone_number") ?? "";
      phone_number=phone_number.replaceFirst("+", "");
    });
    try{
      final response = await http.post(Uri.parse("http://$ip:8000/medicine_pur/create_order_placed_details/"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "pry_phone_number":"${phone_number}",
          "product_number":"${specific_products!.productNumber}",
          "purchase_quantity":"${quantity}",
          "purchase_total_price":"${total_price}",
          "purchase_pay_type":"${selectedPaymentMethod}",
          "order_date":"${delivery_date}"
        }));
      if(response.statusCode==201){
        NotificationService().showNotification(id: 0, title: "Health Hub", body: "${specific_products!.productName} Order Placed Successfully \nDelivered on ${delivery_date}");
        showBottomSheet(context: context, builder: (context)=>order_success());
      }
    }catch(e){
      print("${e.toString()}");
    }
  }
  Future<void> _get_product_number() async{
    int product_number = 0;
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      product_number = (perf.getInt("product_number")??"") as int;
      print("${product_number}");
    });
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/medicine_pur/get_specific_product/$product_number/"));
      if(response.statusCode == 200){
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(()  {
          specific_products = medicine_purchase.fromJson(jsonResponse);
          isChecked = true;
        });
      }else{
        print("error in the program");
        isChecked=true;
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  Future<void> _vibrate() async{
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> _get_patients_address() async{
    // String phone_number ="";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number=phone_number.replaceFirst("+", "");
    });
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/medicine_pur/get_specific_user_specific_address/$phone_number/1/"));
      if(response.statusCode==200){
        Map<String,dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          patients_address = patient_address.fromJson(jsonResponse);
          isChecked = true;
        });
      }
      else{
        print("error in the program");
        isChecked=true;
      }
    }catch(e){
      print("${e.toString()}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Order",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
      body: isChecked
      ?Padding(
        padding:  EdgeInsets.all(15.0),
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
                    ListTile(
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
                                    "${patients_address!.flatHouseName},\n${patients_address!.areaBuildingName},\n${patients_address!.townCity} ${patients_address!.pincode},\n${patients_address!.stateName},\n${patients_address!.secPhoneNumber}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )),
                              TextButton(
                                  onPressed: () {}, child: Text("change"))
                            ],
                          ),
                          TextButton(
                              onPressed: () {}, child: Text("add address"))
                        ],
                      ),
                    ),
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
                          _buildPaymentOption("Cash on delivery", selectedPaymentMethod == "Cash on delivery", _onCashOnDelivery),
                          _buildPaymentOption("VISA ....6766", selectedPaymentMethod == "VISA ....6766", _onVisaPayment),
                          _buildPaymentOption("G Pay", selectedPaymentMethod == "G Pay", _onGPay),

                          SizedBox(height: 20),
                          Text("Arriving $delivery_date", style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
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
                                    child: Image(
                                        image: NetworkImage(
                                            scale: 3,
                                            "http://$ip:8000${specific_products!.productImage}")),
                                  ),
                                  Padding(
                                    padding:  EdgeInsets.all(8.0),
                                    child: Text("delivery time: Wednesday"),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${specific_products!.productName}"),
                                Text("${specific_products!.aboutProduct}"),
                                Text("${specific_products!.cureDisases}"),
                                Text("₹ ${specific_products!.price}")
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(top: 15.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Quantity"),
                                Text("${quantity}")
                              ],
                            ),Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total price"),
                                Text("₹ ${total_price}")
                              ],
                            ),Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Devlivery Cost"),
                                Text("- ₹ 0.00")
                              ],
                            ),Row(
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
                                Text("Total"),
                                Text("₹ ${total_price}")
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
                                _vibrate();
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
              height: 100,
            )
          ],
        ),
      ):Center(child: CircularProgressIndicator(),),
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
          border: Border.all(color: Colors.black,width: 1)
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

