import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_hub/allfun.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../Backend_information/medicine_app_backend/medicine_purchase_backend.dart';
import '../../add_medicine_page.dart';
import 'about_specific_product.dart';


class medi_home_page extends StatefulWidget {
  const medi_home_page({super.key});

  @override
  State<medi_home_page> createState() => _medi_home_pageState();
}

class _medi_home_pageState extends State<medi_home_page> {
  List<medicine_purchase> medical_details = [];
  DateTime now = DateTime.now();
  String formattedseven ="";
  bool isloading=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show_date();
    _get_medicine_detials();
  }

  void show_date(){
    DateTime seven= now.add(Duration(days: 7));
    formattedseven = DateFormat('EEEE').format(seven);
  }

  Future<void> _get_medicine_detials() async {
    try {
      final response = await http.get(
          Uri.parse("http://$ip:8000/medicine_pur/create_medicine_details/"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          medical_details = jsonResponse
              .map((data) => medicine_purchase.fromJson(data))
              .toList();
          isloading=true;
        });
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white54,
            appBar: AppBar(
              backgroundColor: Colors.white54,
              actions: [IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>add_medincine()));
                },
                  icon: Icon(Icons.add,color: Colors.blueAccent,))],
              centerTitle: true,
              title: Text(
                "Health_hub Medical",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            body: isloading
            ?ListView(
              physics: BouncingScrollPhysics(),
              children: [
                ListView.builder(
                  physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: medical_details.length,
                    itemBuilder: (context, index) {
                      var medicine = medical_details[index];
                      return medicine.id != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 28.0,right: 28,bottom: 15),
                              child: Card(
                                color: Colors.white,
                                elevation: 5,
                                clipBehavior: Clip.hardEdge,
                                shadowColor: Colors.grey,
                                child: Padding(
                                  padding:  EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 140,
                                    color: Colors.white,
                                    // height: 160,
                                    // color: Colors.red,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 18.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 150,
                                                 height: 100,
                                                child: Image(
                                                    image: NetworkImage(
                                                        // scale: 50,
                                                        "http://$ip:8000${medicine.productImage}")),
                                              ),
                                              Padding(
                                                padding:  EdgeInsets.all(8.0),
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
                                              Text("${medicine.productName}",overflow: TextOverflow.ellipsis,),
                                              Text("${medicine.cureDisases}",overflow: TextOverflow.ellipsis,),
                                              Text("${medicine.quantity} ml bottle"),
                                              Text("${medicine.price} Rs"),
                                              Padding(
                                                padding:  EdgeInsets.only(top: 10.0),
                                                child: OutlinedButton(
                                                  onPressed: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>specific_product(
                                                      product_number : "${medicine.productNumber}"
                                                    )));
                                                  },
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor: Colors.blueAccent
                                                    ),
                                                    child: Text("order",style: TextStyle(color: Colors.white),)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          :Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
                        height: 100,));
                    }),
              ],
            ):Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
              height: 100,)),
            ),
      );
  }
}
