import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/get_fav_doc_backend.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/pages/home_page/doctor_profile_3.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/user_details_backend.dart';
import '../Profile_page/profile_page.dart';
import 'all_doctor_search.dart';

class all_doctor extends StatefulWidget {
  const all_doctor({super.key});

  @override
  State<all_doctor> createState() => _all_doctorState();
}

class _all_doctorState extends State<all_doctor> with TickerProviderStateMixin{
  update_profile? userprofile;
  bool set_fav = false;
  List<doctor_details> doctor_detail = [];
  List<get_fav_doc> get_fav_doctor = [];
  bool isLoading = true;
  String? errorMessage;
  String doc_id = "";

  // bool like = false;
  String errormessage = "";

  @override
  void initState() {
    super.initState();
    _showdoctor1();
    _show_favorite_doc();
    userpro();
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

  //  request for retrieve the all the json using get
  Future<void> _showdoctor1() async {
    final url = Uri.parse("http://$ip:8000/doctor_details/doctor_addetails/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          doctor_detail = jsonResponse
              .map((data) => doctor_details.fromJson(data))
              .toList();
          print("$doctor_detail");
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "failed to load doctor_details";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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
          errorMessage = response.body.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      errorMessage = e.toString();
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
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "All Doctor",
          style:
          TextStyle(color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchDoctorPage()));
            },
            icon: Icon(Icons.search_rounded),
            color: Color(0xff0a8eac),
          )
        ],
      ),
      body: isLoading
      ?Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
        height: 100,))
      :ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: doctor_detail.length,
                itemBuilder: (context, index) {
                  var doctor = doctor_detail[index];
                  var show_fav_doctor = index < get_fav_doctor.length
                      ? get_fav_doctor[index]
                      : null;
                  return doctor.id != null
                      ? Padding(
                    padding:
                    EdgeInsets.only(bottom: 10),
                    child:AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        horizontalOffset: 500.0,
                        child: FadeInAnimation(
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
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // borderRadius: BorderRadius.circular(40),
                              ),
                              height: 190,
                              // width: 330,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 15, bottom: 15),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(
                                          // scale: 10,
                                          doctor.doctorImage != null
                                              ? "http://$ip:8000${doctor.doctorImage}"
                                              : "no data ",
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 28.0),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "${doctor.doctorName}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 28.0),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        doc_id = doctor_detail[
                                                        index]
                                                            .id
                                                            ?.toString() ??
                                                            '';
                                                        doctor_detail[index]
                                                            .like =
                                                        !(doctor_detail[index]
                                                            .like ??
                                                            false);
                                                        set_fav =
                                                        doctor_detail[index]
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
                                            // Padding(
                                            //   padding: EdgeInsets.only(bottom: 5.0),
                                            //   child: Text(
                                            //     doctor.language ?? "english",
                                            //     style: TextStyle(
                                            //       fontSize: 14,
                                            //     ),
                                            //   ),
                                            // ),
                                            // Padding(
                                            //   padding: EdgeInsets.only(bottom: 5.0),
                                            //   child: Text(
                                            //     doctor.doctorLocation ??
                                            //         "No specility",
                                            //     style: TextStyle(
                                            //       fontSize: 14,
                                            //     ),
                                            //   ),
                                            // ),

                                            Padding(
                                              padding: EdgeInsets.only(top: 8.0),
                                              child: OutlinedButton(
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
                                                        color: Colors.white),
                                                  )),
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
                }),
          ),
          Container(
            height: 100,
          )
        ],
      ),
    );
  }
}
