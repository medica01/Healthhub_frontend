import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
import 'package:health_hub/user%20app/pages/message_page/search_doc_message_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../../../Backend_information/user_details_backend.dart';
import '../../../main.dart';
import '../Profile_page/profile_page.dart';
import 'chatting_user_to_doc_2.dart';

class message_page extends StatefulWidget {
  const message_page({super.key});

  @override
  State<message_page> createState() => _message_pageState();
}

class _message_pageState extends State<message_page> {
  List<doctor_details> chattting_doc = [];
  String errormessage = "";
  update_profile? userprofile;
  bool isLoading = true;
  String phone_number = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatting_doc();
    userpro();
  }

  Future<void> userpro() async {
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.get(
          Uri.parse("http://$ip:8000/user_profile/user_edit/$phone_number/"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          userprofile = update_profile.fromJson(jsonResponse);
          isLoading = false;
        });
      } else {
        setState(() {
          errormessage = response.body.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      isLoading = false;
    }
  }

  Future<void> _online() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    final url =
        Uri.parse("http://$ip:8000/user_profile/user_edit/$phone_number/");
    try {
      final response = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_status": true}));
      if (response.statusCode == 200) {
        print("change user online successfully");
      }
    } catch (e) {
      String e1 = e.toString();
      print("online:$e1");
    }
  }

  Future<void> _chatting_doc() async {
    try {
      final response = await http.get(
        Uri.parse("http://$ip:8000/doctor_details/doctor_addetails/"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = await jsonDecode(response.body);
        setState(() {
          chattting_doc = jsonResponse
              .map((data) => doctor_details.fromJson(data))
              .toList();
          isLoading=false;
        });
      } else {
        setState(() {
          errormessage = "failed to load doctor_details";
          isLoading=false;
        });
      }
    } catch (e) {
      setState(() {
        errormessage = e.toString();
        print("$errormessage");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Active Now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      IconButton(
                          onPressed: () {
                            if (userprofile!.firstName == null) {
                              print("${userprofile!.firstName}");
                              if (userprofile!.lastName == null) {
                                if (userprofile!.age == null) {
                                  if (userprofile!.gender == null) {
                                    if (userprofile!.email == null) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Invalid User",
                                              style: TextStyle(
                                                  color: Colors.red, fontSize: 25),
                                            ),
                                            content: Text(
                                              "you must create the account for chatting!",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             profile_page()));
                                                  },
                                                  child: Text("Ok"))
                                            ],
                                          ));
                                    }
                                  }
                                }
                              }
                            }
                            else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => search_chat_name()));
                            }
                          },
                          icon: Icon(
                            Icons.search,
                            color: Color(0xff1f8acc),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // ✅ Allow horizontal scrolling
                    child: Row(
                      children: chattting_doc.map((show_docc) {
                        return show_docc.id != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                        show_docc.doctorImage != null
                                            ? "http://$ip:8000${show_docc.doctorImage}"
                                            : "no data ",
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      show_docc.doctorName ?? "Unknown",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox();
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Messages",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: chattting_doc.length,
                    itemBuilder: (context, index) {
                      var show_docc = chattting_doc[index];
                      return show_docc.id != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  horizontalOffset: 500.0,
                                  child: FadeInAnimation(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (userprofile!.firstName == null) {
                                          print("${userprofile!.firstName}");
                                          if (userprofile!.lastName == null) {
                                            if (userprofile!.age == null) {
                                              if (userprofile!.gender == null) {
                                                if (userprofile!.email == null) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                              "Invalid User",
                                                              style: TextStyle(
                                                                  color: Colors.red,
                                                                  fontSize: 25),
                                                            ),
                                                            content: Text(
                                                              "you must create the account for chatting!",
                                                              style: TextStyle(
                                                                  fontSize: 20),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder:
                                                                                (context) =>
                                                                                profile_page()));
                                                                  },
                                                                  child: Text("Ok"))
                                                            ],
                                                          ));
                                                }
                                              }
                                            }
                                          }
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => user_doc(
                                                      data:
                                                      "${show_docc.doctorPhoneNo}")));
                                          _online();
                                        }
                                      },
                                      child: Card(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        shadowColor: Colors.grey,
                                        child: Container(
                                          height: 100,
                                          // color: Colors.red,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 40,
                                                  backgroundImage: NetworkImage(
                                                    // scale: 10,
                                                    show_docc.doctorImage != null
                                                        ? "http://$ip:8000${show_docc.doctorImage}"
                                                        : "no data ",
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  EdgeInsets.only(left: 15.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${show_docc.doctorName}",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 20),
                                                      ),
                                                      Text(
                                                        "${show_docc.specialty}",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.bold),
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
                                ),
                              )

                            )
                          : Text("data");
                    })
              ],
            ));
  }
}
