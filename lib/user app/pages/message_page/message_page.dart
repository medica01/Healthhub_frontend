import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/rendering.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: show_all_doctor());
  }
}

class show_all_doctor extends StatefulWidget {
  const show_all_doctor({super.key});

  @override
  State<show_all_doctor> createState() => _show_all_doctorState();
}

class _show_all_doctorState extends State<show_all_doctor> {
  List<doctor_details> chattting_doc = [];
  String errormessage = "";
  update_profile? userprofile;
  bool isLoading = true;

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
        });
      } else {
        setState(() {
          errormessage = "failed to load doctor_details";
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Message",
            style: TextStyle(
                color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
          ),
          actions: [
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
                                        color: Colors.red,
                                        fontSize: 25),
                                  ),
                                  content: Text(
                                    "you must create the account for chatting!",
                                    style:
                                    TextStyle(fontSize: 20),
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
                  }else{
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
        body: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Active Now",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                            builder: (context) => AlertDialog(
                                                  title: Text(
                                                    "Invalid User",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 25),
                                                  ),
                                                  content: Text(
                                                    "you must create the account for chatting!",
                                                    style:
                                                        TextStyle(fontSize: 20),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        padding: EdgeInsets.only(left: 15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${show_docc.doctorName}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              "${show_docc.specialty}",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
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
                        )
                      : Text("data");
                })
          ],
        ));
  }
}

class search_chat_name extends StatefulWidget {
  const search_chat_name({super.key});

  @override
  State<search_chat_name> createState() => _search_chat_nameState();
}

class _search_chat_nameState extends State<search_chat_name> {
  TextEditingController searchController = TextEditingController();
  List<doctor_details> search_doctor = [];
  bool isLoading = false;

  Future<void> _search_doc_name(String query) async {
    if (query.isEmpty) return;
    setState(() {
      isLoading = true;
    });

    try {
      String get_name = Uri.encodeQueryComponent(query);
      final response = await http.get(Uri.parse(
          "http://$ip:8000/doctor_details/doctor_search/?q=$get_name"));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("jsonResponse: $jsonResponse");
        if (jsonResponse is Map && jsonResponse.containsKey('result')) {
          var resultList = jsonResponse['result'];
          if (resultList is List) {
            setState(() {
              search_doctor = resultList
                  .map((data) => doctor_details.fromJson(data))
                  .toList();
              isLoading = false;
            });
          } else {
            setState(() {
              search_doctor = [];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            search_doctor = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          search_doctor = [];
          isLoading = false;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          autofocus: true,
          controller: searchController,
          cursorColor: Color(0xff1f8acc),
          style:
              TextStyle(color: Color(0xff1f8acc), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            focusColor: Colors.black,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.black, width: 2.0), // Focused border color
            ),
            hintText: "Search chats...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (query) {
            if (query.length > 1) {
              _search_doc_name(query);
            }
          },
        ),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: search_doctor.length,
          itemBuilder: (context, index) {
            var show_docc = search_doctor[index];
            return show_docc.id != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => user_doc(
                                    data: "${show_docc.doctorPhoneNo}")));
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    // scale: 10,
                                    show_docc.doctorImage != null
                                        ? "http://$ip:8000/media/${show_docc.doctorImage}"
                                        : "no data ",
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${show_docc.doctorName}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        "${show_docc.specialty}",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
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
                  )
                : Text("data");
          }),
    );
  }
}
