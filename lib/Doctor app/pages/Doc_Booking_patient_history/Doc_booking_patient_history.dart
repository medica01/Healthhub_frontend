import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_Booking_patient_history/search_doc_booking_history.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_Booking_patient_history/specific_patient_details.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class doc_book_pati extends StatefulWidget {
  const doc_book_pati({super.key});

  @override
  State<doc_book_pati> createState() => _doc_book_patiState();
}

class _doc_book_patiState extends State<doc_book_pati> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "booked patient history",
            style: TextStyle(
                color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
          ),
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(60),
          //   child: Padding(
          //     padding: EdgeInsets.only(
          //       left: 10.0,
          //     ),
          //     child: Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Container(
          //           width: 360,
          //           child: SearchBar(
          //             leading: Icon(Icons.search),
          //             hintText: 'Search Booking Doctor',
          //             backgroundColor: WidgetStatePropertyAll(Colors.white),
          //             // shadowColor: WidgetStatePropertyAll(Colors.grey),
          //             elevation: WidgetStatePropertyAll(6.0),
          //             shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20))),
          //             padding: WidgetStatePropertyAll(
          //                 EdgeInsets.symmetric(horizontal: 16.0)),
          //           ),
          //         )),
          //   ),
          // ),
          actions: [
            IconButton(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>search_doc_user_book()));
                },
                icon: Icon(
                  Icons.search,
                  color: Color(0xff1f8acc),
                ))
          ],
        ),
        body: Doc_see_user(),

    );
  }
}

class Doc_see_user extends StatefulWidget {
  const Doc_see_user({super.key});

  @override
  State<Doc_see_user> createState() => _Doc_see_userState();
}

class _Doc_see_userState extends State<Doc_see_user> {
  List<booking_doctor> booking_doc_user = [];
  bool isloading = true;
  String? errormessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _show_booked_user();
  }

  Future<void> _show_booked_user() async {
    String doc_phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_number = pref.getString('doctor_phone_no') ?? "";
      doc_phone_number = doc_phone_number.replaceFirst("+", "");
      print("$doc_phone_number");
    });
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/booking_doctor/spec_doctor_booked/$doc_phone_number/"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          booking_doc_user = jsonResponse
              .map((data) => booking_doctor.fromJson(data))
              .toList();
          print("${booking_doc_user.length}");
          isloading = false;
        });
      } else {
        setState(() {
          errormessage = "failed to load user details";
          isloading = false;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      isloading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                          // width: 330,
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
                                            ? "http://$ip:8000${show_book.userPhoto}"
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
                  );
                }))
      ],
    );
  }
}
