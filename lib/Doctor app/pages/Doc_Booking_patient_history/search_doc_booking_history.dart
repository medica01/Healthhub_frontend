import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_Booking_patient_history/specific_patient_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;

import '../../../main.dart';


class search_doc_user_book extends StatefulWidget {
  const search_doc_user_book({super.key});

  @override
  State<search_doc_user_book> createState() => _search_doc_user_bookState();
}

class _search_doc_user_bookState extends State<search_doc_user_book> {
  TextEditingController searchController = TextEditingController();
  List<booking_doctor> booking_doc_user =[];
  bool isloading=true;
  String? errormessage;

  Future<void> _search_doc_use_book(String query) async{
    String doc_phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_number = pref.getString('doctor_phone_no') ?? "";
      doc_phone_number=doc_phone_number.replaceFirst("+", "");
      print("$doc_phone_number");
    });
    try{
        String docc_phone_number = Uri.encodeQueryComponent(doc_phone_number);
        String  encodedquery= Uri.encodeQueryComponent(query);
        final response = await http.get(Uri.parse("http://$ip:8000/booking_doctor/get_doc_app_booking_history/?doc_phone_number=$docc_phone_number&q=$encodedquery"));
        if(response.statusCode == 200){
          var jsonResponse = jsonDecode(response.body);
          if(jsonResponse is Map && jsonResponse.containsKey('result')){
            var resultList = jsonResponse['result'];
            if(resultList is List){
              setState(() {
                booking_doc_user=resultList.map((data)=>booking_doctor.fromJson(data)).toList();
                isloading = false;
              });

            }else{
              setState(() {
                booking_doc_user =[];
                isloading = false;
              });
            }
          }else{
            setState(() {
              booking_doc_user =[];
              isloading=false;
            });
          }
        }else{
          setState(() {
            booking_doc_user =[];
            isloading=false;
          });
        }
      }catch(e){
        print("object$e");
        setState(() {
          isloading=false;
        });
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: searchController,
          cursorColor: Color(0xff1f8acc),
          style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            focusColor: Colors.black,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color
            ),
            hintText: "Search Doctor...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (query) {
            if (query.length > 1) {
              _search_doc_use_book(query);
            }
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                  itemCount: booking_doc_user.length,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var show_book = booking_doc_user[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child:
                      AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          horizontalOffset: 500.0,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>specific_patient(user_id : "${show_book.id}")));
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.hardEdge,
                                shadowColor: Colors.grey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  height: 190,
                                  width: 330,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0, top: 15, bottom: 15),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                              radius: 50,
                                              backgroundImage: NetworkImage(
                                                show_book.userPhoto != null
                                                    ? "http://$ip:8000/media/${show_book.userPhoto}"
                                                    : "no data ",
                                              )),
                                          Padding(
                                            padding: EdgeInsets.only(left: 28.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${show_book.firstName} ${show_book.lastName}",
                                                      style: TextStyle(
                                                          color: Colors.black, fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 5.0),
                                                  child: Text(
                                                    "age:${show_book.age}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 5.0),
                                                  child: Text(
                                                    "gender: ${show_book.gender}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),Padding(
                                                  padding: EdgeInsets.only(bottom: 5.0),
                                                  child: Text(
                                                    "date: ${show_book.bookingDate}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),Padding(
                                                  padding: EdgeInsets.only(bottom: 5.0),
                                                  child: Text(
                                                    "time: ${show_book.bookingTime}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ),
                        ),
                      )

                    );
                  }))
        ],
      ),
    );
  }
}
