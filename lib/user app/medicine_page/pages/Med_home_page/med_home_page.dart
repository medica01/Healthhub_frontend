import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_hub/allfun.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import '../../../../Backend_information/medicine_app_backend/medicine_purchase_backend.dart';
import 'about_specific_product.dart';

class medi_home_page extends StatefulWidget {
  const medi_home_page({super.key});

  @override
  State<medi_home_page> createState() => _medi_home_pageState();
}

class _medi_home_pageState extends State<medi_home_page> {
  List<medicine_purchase> medical_details = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_medicine_detials();
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
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              // leading: IconButton(onPressed: (){
              //   Navigator.pop(context);
              // }, icon: Icon(Icons.arrow_back)),
              centerTitle: true,
              title: Text(
                "Health_hub Medical",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            body: ListView(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: medical_details.length,
                    itemBuilder: (context, index) {
                      var medicine = medical_details[index];
                      return medicine.id != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 28.0,right: 28,bottom: 15),
                              child: Card(
                                elevation: 5,
                                clipBehavior: Clip.hardEdge,
                                shadowColor: Colors.grey,
                                child: Container(
                                  width: 140,
                                  height: 160,
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
                                              child: Image(
                                                  image: NetworkImage(
                                                      scale: 3,
                                                      "http://$ip:8000${medicine.productImage}")),
                                            ),
                                            Padding(
                                              padding:  EdgeInsets.all(8.0),
                                              child: Text("delivery time: wednesday"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:  EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("${medicine.productName}"),
                                            Text("${medicine.cureDisases}"),
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
                            )
                          : CircularProgressIndicator();
                    }),
              ],
            ),
            ),
      );
  }
}
