import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/medicine_app_backend/medicine_order_details_backend.dart';
import 'package:http/http.dart%20' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../main.dart';


class view_order_details extends StatefulWidget {
  final dynamic id;
  view_order_details({super.key,required this.id});

  @override
  State<view_order_details> createState() => _view_order_detailsState();
}

class _view_order_detailsState extends State<view_order_details> {
  order_placed_details? get_spec_pro;
  bool isloading =false;
  String err = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_order_spec_pro();
  }

  Future<void> _get_order_spec_pro() async{
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
          // get_spec_pro!.orderDate = get_spec_pro!.orderDate!.substring(0, 3);
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


  Widget order_details(
      String text,
      String text2,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 150,
              child: Text(
                text2,
                style: TextStyle(color: Colors.grey, fontSize: 17),
              )),
          Container(child: Text(text))
        ],
      ),
    );
  }

  Widget head(String title){
    return Container(
      child: Text(
        title,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25),
      ),
    );
  }

  Widget price(String txt1,String txt2){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(txt1,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        Text(txt2,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: isloading
      ?Padding(
        padding: EdgeInsets.only(left: 15.0, right: 10, bottom: 10),
        child: ListView(
          children: [
            head("View order details"),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1)),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      order_details("${get_spec_pro!.orderDate}", "Order date"),
                      order_details("₹ ${get_spec_pro!.purchaseTotalPrice} (${get_spec_pro!.purchaseQuantity} item)", "Order Total"),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 1,
                        endIndent: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Cancel items",
                                  style: TextStyle(
                                      color: Colors.black,
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                Icon(Icons.arrow_forward_ios,size: 25,)
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                clipBehavior: Clip.hardEdge,
                // height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Arriving ${get_spec_pro!.orderDate}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image(
                                        image: NetworkImage(
                                            scale: 5 ,
                                            "http://$ip:8000${get_spec_pro!.productImage}"))),
                                SizedBox(
                                  width: 30,
                                ),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Text(
                                                softWrap: true,
                                                "${get_spec_pro!.productName} ${get_spec_pro!.aboutProduct}")),
                                        Text("₹ ${get_spec_pro!.purchaseTotalPrice}.00")
                                      ],
                                     ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider(
                    //   color: Colors.grey,
                    //   thickness: 1,
                    //   indent: 5,
                    //   endIndent: 5,
                    // ),
                    // Padding(
                    //   padding:  EdgeInsets.only(left: 20.0,bottom: 10,top: 10,right: 20),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text("Track package",style: TextStyle(color: Colors.black,),),
                    //       Icon(Icons.arrow_forward_ios)
                    //     ],
                    //   ),
                    // ),
                    // Divider(
                    //   color: Colors.grey,
                    //   thickness: 1,
                    //   indent: 5,
                    //   endIndent: 5,
                    // ),
                    Column(
                      children: [
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 3,
                          endIndent: 3,
                        ),
                        Padding(
                          padding:  EdgeInsets.only(left: 20.0,bottom: 15,top: 10,right: 20),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              // height: 50,
                              // width: 300,
                              decoration: BoxDecoration(
                                  color: Colors.transparent
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Track package",style: TextStyle(color: Colors.black,),),
                                  Icon(Icons.arrow_forward_ios,size: 20,)
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding:  EdgeInsets.only(left: 20.0,bottom: 20,right: 20),
                        //   child: Container(
                        //     height: 20,
                        //     width: 300,
                        //     decoration: BoxDecoration(
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text("Track package",style: TextStyle(color: Colors.black,),),
                        //         Icon(Icons.arrow_forward_ios)
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            head("Payment Information"),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                // height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1)),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text("Payment Methods",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 17),),
                        Text("${get_spec_pro!.purchasePayType}",style: TextStyle(color: Colors.black,),),
                        SizedBox(
                          height: 30,
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 3,
                          endIndent: 3,
                        ),
                        Padding(
                          padding:  EdgeInsets.only(left: 20.0,bottom: 10,top: 10,right: 20),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(

                              color: Colors.transparent,

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Change Payment Method",style: TextStyle(color: Colors.black,),),
                                  Icon(Icons.arrow_forward_ios,size: 20,)
                                ],
                              ),
                            ),
                          ),)
                      ]
                  ),
                ),
              ),
            ),
            head("Ship to"),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      Text("Phone number: ${get_spec_pro!.secPhoneNumber}")
                    ],
                  ),
                ),
              ),
            ),
            head("Order Summary"),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(

                // height: 50,
                decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey, width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      price("Item:", "Rs. ${get_spec_pro!.purchaseTotalPrice}"),
                      price("Postage & packing:", "Rs. 0.00"),
                      price("${get_spec_pro!.purchasePayType} delivery Fee:", "Rs. 0.00"),
                      price("Total:", "Rs. ${get_spec_pro!.purchaseTotalPrice}"),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order Total",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 19),),
                      Text("Rs. ${get_spec_pro!.purchaseTotalPrice}.00",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 19),)
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 100,
            )
          ],
        ),
      ):Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
        height: 100,))
    );
  }
}