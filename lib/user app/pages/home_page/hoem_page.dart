import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Notification_services.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/pages/home_page/all_doctor_2.dart';
import 'package:health_hub/user%20app/pages/home_page/doctor_profile_3.dart';
import 'package:health_hub/user%20app/pages/home_page/specific_doctor_4.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/user_details_backend.dart';
import '../../../allfun.dart';
import '../../Other_feature/show_favorite_doc.dart';
import '../Profile_page/profile_page.dart';
import 'category_grid_doc_6.dart';

class main_home extends StatefulWidget {
  const main_home({super.key});

  @override
  State<main_home> createState() => _main_homeState();
}

class _main_homeState extends State<main_home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home_page(),
    );
  }
}

class home_page extends StatefulWidget {
  const home_page({super.key});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  bool heart = false;
  List<doctor_details> doctor_detail = [];
  bool isLoading = true;
  String? errormessage;
  update_profile? userprofile;

  @override
  void initState() {
    super.initState();
    _name();
    _showdoctor();
    userpro();
  }

  Future<void> _showdoctor() async {
    final url = Uri.parse(
        "http://$ip:8000/doctor_details/doctor_editdetails/27/"); // Specific doctor's details
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          doctor_detail = [doctor_details.fromJson(jsonResponse)];
          isLoading = false;
        });
        print(jsonResponse); // Log raw JSON response
      } else {
        setState(() {
          errormessage = "Failed to load doctor details.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errormessage = e.toString();
        isLoading = false;
      });
    }
  }

  String name = "";
  String photourl = "";

  final List<String> images = [
    "https://static.vecteezy.com/system/resources/previews/016/699/936/non_2x/book-doctor-appointment-online-flat-banner-template-making-visit-poster-leaflet-printable-color-designs-editable-flyer-page-with-text-space-vector.jpg",
    "https://i.postimg.cc/zvxSktP1/freelance-hub-job-portal-logo.jpg"
    // "https://img.freepik.com/free-psd/medical-business-social-media-promo-template_23-2149488299.jpg?uid=R162018176&ga=GA1.1.249085122.1736660184&semt=ais_incoming",
    // "https://img.freepik.com/free-psd/medical-business-horizontal-banner-template_23-2149488295.jpg?uid=R162018176&ga=GA1.1.249085122.1736660184&semt=ais_incoming"
  ];

  Future<void> _name() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = pref.getString("name") ?? "guest";
      photourl = pref.getString("photourl") ?? "no img";
    });
  }

  Widget a(String text, BuildContext context, Widget page) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => page));
          },
          child: Container(
            height: 100,
            width: 150,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
                child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )),
          ),
        );
      }),
    );
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

  @override
  Widget build(BuildContext context) {
    return userprofile != null
        ? Scaffold(
      backgroundColor: Colors.white54,
            appBar: AppBar(
              backgroundColor: Colors.white54,
              title: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => profile_page()));
                      },
                      child: CircleAvatar(
                        radius: 22.0,
                        backgroundImage: userprofile!.userPhoto != null
                            ? NetworkImage(
                                "http://$ip:8000${userprofile!.userPhoto}")
                            : NetworkImage("https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi,Welcome,",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        userprofile!.firstName != null ||
                                userprofile!.lastName != null
                            ? Text(
                                "${userprofile!.firstName ?? ""} ${userprofile!.lastName ?? ""}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text("Guest",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => show_fav_doc()));
                    },
                    icon: Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                      size: 30,
                    )),
                IconButton(
                    onPressed: () async{
                      await NotificationService().init();
                    },
                    icon: Icon(
                      Icons.notifications_active_outlined,
                      size: 30,
                    )),
              ],
              // bottom: PreferredSize(
              //   preferredSize: Size.fromHeight(60),
              //   child: Padding(
              //     padding: EdgeInsets.only(
              //       left: 10.0,
              //     ),
              //     child: Padding(
              //         padding: EdgeInsets.all(8.0),
              //         child: Container(
              //           width: 320,
              //           child: SearchBar(
              //             leading: Icon(Icons.search),
              //             hintText: 'Search',
              //             backgroundColor: WidgetStatePropertyAll(Colors.white),
              //             shadowColor: WidgetStatePropertyAll(Colors.grey),
              //             elevation: WidgetStatePropertyAll(6.0),
              //             shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(40))),
              //             padding: WidgetStatePropertyAll(
              //                 EdgeInsets.symmetric(horizontal: 16.0)),
              //           ),
              //         )),
              //   ),
              // ),
            ),
            body: ListView(
              children: [
                userprofile!.firstName == null ||
                        userprofile!.lastName == null ||
                        userprofile!.email == null ||
                        userprofile!.gender == null ||
                        userprofile!.age == null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 5),
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Did you want to Create Account!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.blueAccent, width: 1)),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>profile_page()));
                                  },
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(color: Colors.blueAccent),
                                  ))
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Container(
                    child: CarouselSlider(
                      items: images
                          .map((imagePath) => ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imagePath,
                                  fit: BoxFit.fill,

                                  width: double.infinity,
                                ),
                              ))
                          .toList(),
                      options: CarouselOptions(
                        height: 230.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 5),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        clipBehavior: Clip.hardEdge,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 15.0, right: 8.0, top: 25, bottom: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("Categories", Colors.black, 24, FontWeight.bold),
                      // GestureDetector(
                      //     onTap: () {
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => cate_doc()));
                      //     },
                      //     child: text(
                      //         "See All", Colors.grey, 20, FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        a("Dentist", context, Specific(data: "General")),
                        a(
                            "Therapist",
                            context,
                            Specific(
                              data: "Therapist",
                            )),
                        a(
                            "Orthodontist",
                            context,
                            Specific(
                              data: "Orthodontist",
                            )),
                        a(
                            "Periodontist",
                            context,
                            Specific(
                              data: "Periodontist",
                            )),
                        a(
                            "Oral Surgeon",
                            context,
                            Specific(
                              data: "Oral Surgeon",
                            )),
                        a(
                            "General Surgeon",
                            context,
                            Specific(
                              data: "General doctor",
                            )),
                        a(
                            "Pediatrician",
                            context,
                            Specific(
                              data: "Pediatrician",
                            )),
                        a(
                            "Ophthalmologist",
                            context,
                            Specific(
                              data: "Ophthalmologist",
                            )),
                        a(
                            "Cardiologist",
                            context,
                            Specific(
                              data: "Cardiologist",
                            )),
                        a(
                            "Physiotherapist",
                            context,
                            Specific(
                              data: "Physiotherapist",
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 15.0, right: 8.0, top: 25, bottom: 25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text("All Doctors", Colors.black, 24, FontWeight.bold),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => all_doctor()));
                          },
                          child: text(
                              "See All", Colors.grey, 20, FontWeight.bold)),
                    ],
                  ),
                ),
                ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: doctor_detail.length,
                    itemBuilder: (context, index) {
                      var doctor = doctor_detail[index];
                      return doctor.id != null
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 13.0, right: 13, bottom: 15),
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
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // borderRadius: BorderRadius.circular(40),
                                  ),
                                  height: 190,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.0, top: 15, bottom: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                          padding: EdgeInsets.only(left: 18.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 5.0),
                                                child: Text(
                                                  "${doctor.doctorName ?? "unknown"}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  doctor.specialty ??
                                                      "No specility",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(
                                                  "${doctor.service ?? "No service"} years of exp",
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
                                                                    Colors
                                                                        .grey),
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
                          : Text("data");
                    }),
                Container(
                  height: 300,
                )
              ],
            ),
          )
        : Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
      height: 100,)
    );
  }
}
