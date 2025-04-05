import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/pages/Booking_history/search_booking_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'get_specific_doc_user_date_time.dart';

class booking_history_page extends StatefulWidget {
  const booking_history_page({super.key});

  @override
  State<booking_history_page> createState() => _booking_history_pageState();
}

class _booking_history_pageState extends State<booking_history_page> {
  List<booking_doctor> booking_doc = [];
  bool isloading = false;
  String? errormessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _show_booking_doc();
    // booking_doc.reversed;
  }

  // request retrieve for the many json in the specific data send
  Future<void> _show_booking_doc() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/booking_doctor/spec_user_booking/$phone_number/"),
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          booking_doc = jsonResponse
              .map((data) => booking_doctor.fromJson(data))
              .toList();
          isloading = true;
        });
      } else {
        setState(() {
          errormessage = "failed to load doctor details";
          isloading = true;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      isloading = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                "Booking History",
                style: TextStyle(
                    color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => search_booking_history()));
                    },
                    icon: Icon(
                      Icons.search,
                      color: Color(0xff1f8acc),
                    ))
              ],
            ),
            body: isloading
                ? (booking_doc.isEmpty
                    ? Center(
                        child: Text(
                          "No Booking Found",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: ListView.builder(
                              itemCount: booking_doc.length,
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var show_doc = booking_doc[index];
                                print("doctor name :${show_doc.doctorName}");
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              get_spec_doc_user_dat_tim(
                                            doc_id: "${show_doc.id}",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      shadowColor: Colors.grey,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        height: 190,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 10.0,
                                              top: 15,
                                              bottom: 15),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage:
                                                      NetworkImage(
                                                    show_doc.doctorImage !=
                                                            null
                                                        ? "http://$ip:8000${show_doc.doctorImage}"
                                                        : "no data ",
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 28.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${show_doc.doctorName}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5.0),
                                                        child: Text(
                                                          "${show_doc.specialty}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5.0),
                                                        child: Text(
                                                          "${show_doc.service} years of exp",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5.0),
                                                        child: Text(
                                                            "Date: ${show_doc.bookingDate}"),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5.0),
                                                        child: Text(
                                                            "Time: ${show_doc.bookingTime}"),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            height: 100,
                          )
                        ],
                      )
            )
                : Center(child: CircularProgressIndicator()
            )
        )
    );
  }
}

