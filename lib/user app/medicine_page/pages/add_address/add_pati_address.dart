import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/medicine_app_backend/patient_address_backend.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/medicine_page/pages/Med_home_page/order_successfully.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../allfun.dart';
import '../Med_home_page/Place_order.dart';

class add_pati_address extends StatefulWidget {
   add_pati_address({super.key,});

  @override
  State<add_pati_address> createState() => _add_pati_addressState();
}

class _add_pati_addressState extends State<add_pati_address> {
  TextEditingController full_name = TextEditingController();
  TextEditingController sec_phone_number = TextEditingController();
  TextEditingController flat_name = TextEditingController();
  TextEditingController area_name = TextEditingController();
  TextEditingController land_mark = TextEditingController();
  TextEditingController pin_code = TextEditingController();
  TextEditingController town_name = TextEditingController();
  TextEditingController state_name = TextEditingController();
  bool isChecked = false;

  void valid_address(){
    List missingfield =[];
    if(full_name.text.isEmpty){
      missingfield.add("please enter the name");
    }if(sec_phone_number.text.isEmpty || sec_phone_number.text.length!=10){
      missingfield.add("please enter the phone_number");
    }if(flat_name.text.isEmpty){
      missingfield.add("please enter the Flat,House no, Building, Company, Apartment name");
    }if(area_name.text.isEmpty){
      missingfield.add("please enter the Area / Building name");
    }if(land_mark.text.isEmpty){
      missingfield.add("please enter any land mark");
    }if(pin_code.text.isEmpty|| pin_code.text.length!=6){
      missingfield.add("please enter the pincode");
    }if(town_name.text.isEmpty){
      missingfield.add("please enter the Town or City name");
    }if(state_name.text.isEmpty){
      missingfield.add("please enter the State name");
    }
    if(missingfield.isNotEmpty){
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: Text("Fill the Address",style: TextStyle(color: Colors.red,fontSize: 25,fontWeight: FontWeight.bold),),
        content: Text("${missingfield.join("\n")}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("Ok",style: TextStyle(color: Colors.red),))
        ],
      ));
    }else{
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: Text("Notice!",style: TextStyle(color: Colors.green,fontSize: 25,fontWeight: FontWeight.bold),),
        content: Text("makes sure the address is correct!",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Cancel",style: TextStyle(color: Colors.red),)),
              TextButton(onPressed: (){
                _send_pati_address();
                Navigator.pop(context);
              }, child: Text("Ok",style: TextStyle(color: Colors.green),)),
            ],
          )
        ],
      ));
    }
  }

  Future<void> _get_patients_address() async{
     String phone_number ="";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number=phone_number.replaceFirst("+", "");
    });
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/medicine_pur/get_specific_user_specific_address/$phone_number/1/"));
      if(response.statusCode==200){
        showDialog(context: context, builder: (context)=>AlertDialog(
          title: Text("Notice!",style: TextStyle(color: Colors.green,fontSize: 25,fontWeight: FontWeight.bold),),
          content: Text("you want to add new address go to add address!",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Cancel",style: TextStyle(color: Colors.red),)),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Ok",style: TextStyle(color: Colors.green),)),
              ],
            )
          ],
        ));
      }
      else{
        valid_address();
        print("error in the program");
        isChecked=true;
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  Future<void> _send_pati_address() async{
    String phone_number ="";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number= perf.getString("phone_number") ??"";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try{
      final response = await http.post(Uri.parse("http://$ip:8000/medicine_pur/create_pati_address/"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
            "full_name": full_name.text,
            "pry_phone_number": phone_number,
            "sec_phone_number": sec_phone_number.text,
            "flat_house_name": flat_name.text,
            "area_building_name": area_name.text,
            "landmark": land_mark.text,
            "pincode": pin_code.text,
            "town_city": town_name.text,
            "state_name": state_name.text
        })
      );
      if(response.statusCode==201){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>place_order(
      )));
        print("${response.body}");
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
        Text(
          "add the address",
          style: TextStyle(color: Colors.blueAccent),
        ),
        actions: [TextButton(onPressed: () {}, child: Text("Cancel"))],
      ),
      body: Form(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: ListView(
            children: [
              Text(
                "Add the address",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  bottom: 14,
                  left: 13,
                  right: 13,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      form(
                        "Full name",
                        350,
                        1000,
                        "",
                        TextInputType.text,
                        full_name
                      ),
                      form(
                        "Mobile number",
                        350,
                        10,
                        "",
                        TextInputType.number,
                        sec_phone_number,
                      ),
                      form(
                        "Flat,House no, Building, Company, Apartment",
                        350,
                        1000,
                        "",
                        TextInputType.text,
                        flat_name,
                      ),
                      form(
                        "Area /Building name",
                        350,
                        1000,
                        "",
                        TextInputType.text,
                        area_name,
                      ),
                      form(
                        "Landmark",
                        350,
                        1000,
                        " E.g. near sjc collage",
                        TextInputType.text,
                        land_mark,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          form(
                            "Pincode",
                            160,
                            6,
                            "6-digit Pincode",
                            TextInputType.number,
                            pin_code,
                          ),
                          form(
                            "Town/City",
                            160,
                            100,
                            "",
                            TextInputType.text,
                            town_name,
                          ),
                        ],
                      ),
                      form(
                        "State",
                        350,
                        100,
                        "",
                        TextInputType.text,
                        state_name,
                      ),
                      // Row(
                      //   children: [
                      //     Checkbox(
                      //       visualDensity: VisualDensity(
                      //         horizontal: 4.0,
                      //         vertical: 0.0,
                      //       ),
                      //       // Max is 4.0
                      //       checkColor: Colors.white,
                      //       focusColor: Colors.blueAccent,
                      //       activeColor: Colors.blueAccent,
                      //       value: isChecked,
                      //       onChanged: (bool? value) {
                      //         setState(() {
                      //           isChecked = value!;
                      //         });
                      //       },
                      //     ),
                      //     Text(
                      //       "Make this my default address",
                      //       style: TextStyle(fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                      Center(
                        child: Container(
                          width: 300,
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                elevation: 5,
                                shadowColor: Colors.grey,
                                backgroundColor: Colors.blueAccent
                            ),
                            onPressed: () {
                              _get_patients_address();
                            },
                            child: Text(
                              "Add Address",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}


