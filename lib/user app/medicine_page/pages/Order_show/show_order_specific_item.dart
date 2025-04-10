import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/medicine_app_backend/medicine_order_details_backend.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart%20' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Notification_services.dart';
import '../Med_home_page/about_specific_product.dart';
import 'Order_show.dart';
import 'order_product_more_info.dart';

class show_spe_order_pro extends StatefulWidget {
  final dynamic id;

  show_spe_order_pro({super.key, required this.id});

  @override
  State<show_spe_order_pro> createState() => _show_spe_order_proState();
}

class _show_spe_order_proState extends State<show_spe_order_pro> {
  order_placed_details? get_spec_pro;
  bool isloading = false;
  String err = "";
  String finaldate = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_spec_order_pro();
  }

  Future<void> _get_spec_order_pro() async {
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/medicine_pur/get_order_placed_specific_details/$phone_number/${widget.id}/"));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_spec_pro = order_placed_details.fromJson(jsonResponse);
          get_spec_pro!.orderDate = get_spec_pro!.orderDate!.substring(0, 3);
          isloading = true;
        });
      } else {
        err = "err in the backend connect";
        print("$err");
        isloading = true;
      }
    } catch (e) {
      err = e.toString();
      print("$err");
    }
  }

  Future<void> _delete_order_placed() async{
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try{
      final response = await http.delete(Uri.parse("http://$ip:8000/medicine_pur/delete_order_product/$phone_number/${widget.id}/"));
      if(response.statusCode==204){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>show_order_placed()), (route)=>false);
        NotificationService().showNotification(id: 0, title: "Health Hub", body: "${get_spec_pro!.productName} Order Canceled Successfully");
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  Widget option(String name) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10)),
        height: 65,
        width: 170,
        child: Center(
            child: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: Text(""),
      ),
      body: isloading
          ? Padding(
              padding: EdgeInsets.only(left: 15.0, right: 10, bottom: 10),
              child: ListView(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Arriving ${get_spec_pro!.orderDate}",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "See all orders",
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.black, width: 0.1)),
                          width: 350,
                          // height: 43,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Image(
                                image: NetworkImage(
                                    scale: 2,
                                    "http://$ip:8000${get_spec_pro!.productImage}")),
                          ),
                        ),
                        Container(
                          height: 150,
                          color: Colors.red,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: GestureDetector(
                                      onTap: (){
                                        showDialog(context: context, builder: (context)=>AlertDialog(
                                          title: Text("Notice!",style: TextStyle(color: Colors.red),),
                                          content: Text("did you want to cancel the order?"),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextButton(onPressed: (){
                                                  Navigator.pop(context);
                                                }, child: Text("Cancel",style: TextStyle(color: Colors.green),)),
                                                TextButton(onPressed: (){
                                                  _delete_order_placed();
                                                  Navigator.pop(context);
                                                }, child: Text("Ok",style: TextStyle(color: Colors.red),)),

                                              ],
                                            )
                                          ],
                                        ));
                                      },
                                        child: option("Cancel Order"))),
                                option("Update delivery \n    Instructions"),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  specific_product(
                                                      product_number:
                                                          "${get_spec_pro!.productNumber}")));
                                    },
                                    child: option("Buy Again")),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: ListTile(
                              title: Text(
                                "Shipping Address",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${get_spec_pro!.fullName}"),
                                    Text(
                                        "${get_spec_pro!.flatHouseName},${get_spec_pro!.areaBuildingName},${get_spec_pro!.townCity}"),
                                    Text(
                                        "${get_spec_pro!.areaBuildingName},${get_spec_pro!.townCity}"),
                                    Text("${get_spec_pro!.pincode}"),
                                    Text(
                                        "Phone number: ${get_spec_pro!.secPhoneNumber}")
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: ListTile(
                            title: Text(
                              "Order Info",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            subtitle: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            view_order_details(
                                                id: "${get_spec_pro!.id}")));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    indent: 5,
                                    endIndent: 5,
                                  ),
                                  ListTile(
                                    title: Text("View order details"),
                                    trailing: Icon(Icons.arrow_forward_ios),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    indent: 3,
                                    endIndent: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Items from your Wish List",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        IconButton(
                            onPressed: () {}, icon: Icon(Icons.more_vert))
                      ],
                    ),
                  ),
                  Container(
                    height: 100,
                  )
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
