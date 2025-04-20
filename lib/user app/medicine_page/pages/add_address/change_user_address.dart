import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:health_hub/user%20app/medicine_page/pages/medical_home.dart';
import 'package:health_hub/user%20app/pages/Profile_page/profile_page.dart';
import 'package:http/http.dart%20' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Backend_information/medicine_app_backend/patient_address_backend.dart';
import '../../../../main.dart';

class change_user_address extends StatefulWidget {
  const change_user_address({super.key});

  @override
  State<change_user_address> createState() => _change_user_addressState();
}

class _change_user_addressState extends State<change_user_address> {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Change Address",style: TextStyle(color: Colors.blueAccent),),
      ),
      body: isloading
    ? SingleChildScrollView(
    child: Container(
    clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40))
      ),
      height: 500,
      child: Column(
        children: [
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
                                onTap: ()  {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          "Notice!",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                          "You want to change address!",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(color: Colors.red),
                                                  )),
                                              TextButton(
                                                  onPressed: () async{
                                                    SharedPreferences pref = await SharedPreferences
                                                        .getInstance();
                                                    pref.setInt("address_id",
                                                        user_add.sequenceNumber ?? 1);
                                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Medical_main_page()),
                                                        (route)=>false);
                                                  },
                                                  child: Text(
                                                    "Ok",
                                                    style: TextStyle(color: Colors.green),
                                                  )),
                                            ],
                                          )
                                        ],
                                      ));

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
    height: 100,))
    );
  }
}
