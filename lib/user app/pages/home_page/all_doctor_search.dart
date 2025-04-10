import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../Backend_information/get_fav_doc_backend.dart';
import '../../../Backend_information/user_details_backend.dart';
import '../Profile_page/profile_page.dart';
import 'doctor_profile_3.dart';

class SearchDoctorPage extends StatefulWidget {
  @override
  _SearchDoctorPageState createState() => _SearchDoctorPageState();
}

class _SearchDoctorPageState extends State<SearchDoctorPage> {
  TextEditingController searchController = TextEditingController();
  List<doctor_details> search_doctor = [];
  bool isLoading = false;
  List<get_fav_doc> get_fav_doctor = [];
  bool set_fav = false;
  String doc_id = "";
  update_profile? userprofile;
  String errormessage ="";

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   userpro();
  //   _show_favorite_doc();
  //
  // }
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

  void valid_user() {
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
                      style: TextStyle(color: Colors.red, fontSize: 25),
                    ),
                    content: Text(
                      "you must create the account for make favorite!",
                      style: TextStyle(fontSize: 20),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => profile_page()));
                          },
                          child: Text("Ok"))
                    ],
                  ));
            }
          }
        }
      }
    } else {
      _favorite_doctor();
    }
  }



  Future<void> _show_favorite_doc() async {
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.get(
        Uri.parse("http://$ip:8000/booking_doctor/get_fav_doc/$phone_number/"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_fav_doctor =
              jsonResponse.map((data) => get_fav_doc.fromJson(data)).toList();
          print("${response.body}");
        });
      } else {
        setState(() {
          errormessage = "failed to load favorite doctor details";
        });
      }
    } catch (e) {
      errormessage = e.toString();
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Alert Message",
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            content: Text(
              "$errormessage",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"))
            ],
          ));
    }
  }

  // Function to fetch doctors
  Future<void> searchDoctors(String query) async {
    if (query.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    try {
      String encodedQuery = Uri.encodeQueryComponent(query);
      final response = await http.get(
        Uri.parse("http://$ip:8000/doctor_details/doctor_search/?q=$encodedQuery"),
      );
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        userpro();
        _show_favorite_doc();
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
            // _show_favorite_doc();
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
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _favorite_doctor() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.post(
          Uri.parse("http://$ip:8000/booking_doctor/create_favorite_doc/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {"id": doc_id, "like": set_fav, "phone_number": phone_number}));
      if (response.statusCode == 201) {
        _show_favorite_doc();
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Alert",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              content: Text(
                "This Doctor already marked as a favorite",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ));
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              "Alert",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            content: Text("$e"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("ok"))
            ],
          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: TextField(
        autofocus: true,
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
            searchDoctors(query);
          }
        },
      ),),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? CircularProgressIndicator()
            : Expanded(
          child: search_doctor.isEmpty
              ? Center(child: Text("No doctors found"))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: search_doctor.length,
            itemBuilder: (context, index) {
              var doctor = search_doctor[index];
              var show_fav_doctor = index < get_fav_doctor.length
                  ? get_fav_doctor[index]
                  : null;
              return doctor.id !=null
                  ? Card(
                    margin: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.hardEdge,
                    shadowColor: Colors.grey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(40),
                      ),
                      height: 190,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10.0, top: 15, bottom: 15),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  // scale: 10,
                                  doctor != null
                                      ? "http://$ip:8000/media/${doctor.doctorImage}"
                                      : "no data ",
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 18.0),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          "${doctor.doctorName}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              left: 28.0),
                                          child:
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                doc_id = search_doctor[
                                                index]
                                                    .id
                                                    ?.toString() ??
                                                    '';
                                                search_doctor[index]
                                                    .like =
                                                !(search_doctor[index]
                                                    .like ??
                                                    false);
                                                set_fav =
                                                search_doctor[index]
                                                    .like!;
                                                valid_user();

                                                // _add_like_doctor_details();
                                              });
                                            },
                                            icon: Icon(
                                              show_fav_doctor != null &&
                                                  show_fav_doctor
                                                      .id !=
                                                      null &&
                                                  show_fav_doctor
                                                      .like ==
                                                      true
                                                  ? FontAwesomeIcons
                                                  .solidHeart
                                                  : FontAwesomeIcons
                                                  .heart,
                                              color: show_fav_doctor !=
                                                  null &&
                                                  show_fav_doctor
                                                      .id !=
                                                      null &&
                                                  show_fav_doctor
                                                      .like ==
                                                      true
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        "${doctor.specialty}",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        "${doctor.service} years of exp",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding:
                                      EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                            doc_profile(
                                                              data:
                                                              "${doctor.id}",
                                                            )));
                                              },
                                              style: OutlinedButton
                                                  .styleFrom(
                                                  backgroundColor:
                                                  Colors
                                                      .blueAccent,
                                                  shadowColor:
                                                  Colors.grey),
                                              child: Text(
                                                "Book",
                                                style: TextStyle(
                                                    color:
                                                    Colors.white),
                                              )),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  : Text("no data");
            },
          ),
        ),
      ),
    );
  }
}