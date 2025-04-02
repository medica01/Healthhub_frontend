import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/get_fav_doc_backend.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/pages/home_page/doctor_profile_3.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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

class _all_doctorState extends State<all_doctor> {
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
      body: ListView(
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
                              EdgeInsets.only(left: 13.0, right: 13, bottom: 15),
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
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 15, bottom: 15),
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(
                                          // scale: 10,
                                          doctor != null
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
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
                                                            color: Colors.white),
                                                      )),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 38.0),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.yellow,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                      width: 60,
                                                      child: Text(
                                                          "${doctor.regNo ?? 0}")),
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
                          ),
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

// import 'dart:convert';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../Backend_doctor_details.dart';
// import '../../../main.dart';
// import 'doctor_profile_3.dart';
//
// class AllDoctor extends StatefulWidget {
//   const AllDoctor({super.key});
//
//   @override
//   State<AllDoctor> createState() => _AllDoctorState();
// }
//
// class _AllDoctorState extends State<AllDoctor> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: const Text(
//           "All Doctor",
//           style: TextStyle(color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: const DoctorList(),
//     );
//   }
// }
//
// class DoctorList extends StatefulWidget {
//   const DoctorList({super.key});
//
//   @override
//   State<DoctorList> createState() => _DoctorListState();
// }
//
// class _DoctorListState extends State<DoctorList> {
//   List<doctor_details> doctorDetail = [];
//   bool isLoading = true;
//   String? errorMessage;
//   String docId = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDoctors();
//   }
//
//   // Fetch all doctors
//   Future<void> _fetchDoctors() async {
//     final url = Uri.parse("http://$ip:8000/doctor_details/doctor_addetails/");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         List<dynamic> jsonResponse = jsonDecode(response.body);
//         List<doctor_details> doctors = jsonResponse.map((data) => doctor_details.fromJson(data)).toList();
//
//         // Load favorites from SharedPreferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         for (var doctor in doctors) {
//           doctor.like = prefs.getBool('fav_${doctor.id}') ?? false;
//         }
//
//         setState(() {
//           doctorDetail = doctors;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = "Failed to load doctor details";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }
//
//   // Toggle favorite doctor
//   Future<void> _toggleFavorite(int index) async {
//     final doctor = doctorDetail[index];
//     String phone_number ="";
//     bool newFavStatus = !(doctor.like ?? false);
//
//     // Save locally
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('fav_${doctor.id}', newFavStatus);
//
//     setState(() {
//       phone_number = prefs.getString('phone_number') ?? "917845711277";
//       phone_number = phone_number.replaceFirst('+', '');
//       doctorDetail[index].like = newFavStatus;
//     });
//
//     // Send to backend
//     try {
//       final response = await http.post(
//         Uri.parse("http://$ip:8000/booking_doctor/create_favorite_doc/"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "id": doctor.id,
//           "like": newFavStatus,
//           "phone_number": phone_number
//         }),
//       );
//
//
//         if (response.statusCode == 201) {
//           showDialog(context: context, builder: (context)=>AlertDialog(
//             title: Text("your like add",style: TextStyle(color: Colors.green,fontSize: 25,fontWeight: FontWeight.bold),),
//             content: Text("this doctor is like by you."),
//
//           ));
//         } else {
//           print('update user details failed:${response.body}');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text("Update user details failed: ${response.body}")),
//           );
//         }
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $e")),
//       );
//     }
//   }
//
//   Future<void> deleteFavoriteDoctor(String phoneNumber, int doctorId) async {
//     final String url = 'http://$ip:8000/booking_doctor/delete_fav_doc/';
//
//     try {
//       final response = await http.delete(
//         Uri.parse(url),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "phone_number": phoneNumber,
//           "doctor_id": doctorId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print("Doctor removed from favorites");
//       } else {
//         print("Error: ${response.body}");
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (errorMessage != null) {
//       return Center(child: Text(errorMessage!));
//     }
//
//     return ListView.builder(
//       physics: const BouncingScrollPhysics(),
//       itemCount: doctorDetail.length,
//       itemBuilder: (context, index) {
//         var doctor = doctorDetail[index];
//
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
//           child: Card(
//             elevation: 5,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             child: Container(
//               decoration: const BoxDecoration(color: Colors.white),
//               height: 190,
//               padding: const EdgeInsets.all(15),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundImage: NetworkImage(
//                       doctor.doctorImage != null ? "http://$ip:8000${doctor.doctorImage}" : "no data",
//                     ),
//                   ),
//                   const SizedBox(width: 18),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 doctor.doctorName ?? "Unknown",
//                                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => _toggleFavorite(index),
//                               icon: Icon(
//                                 doctor.like == true ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
//                                 color: doctor.like == true ? Colors.red : Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 5),
//                         Text("${doctor.specialty ?? "No specialty"}", style: const TextStyle(fontSize: 14)),
//                         Text("${doctor.service} years of experience", style: const TextStyle(fontSize: 14)),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             OutlinedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => doc_profile(data: "${doctor.id}"),
//                                   ),
//                                 );
//                               },
//                               style: OutlinedButton.styleFrom(backgroundColor: Colors.blueAccent),
//                               child: const Text("Book", style: TextStyle(color: Colors.white)),
//                             ),
//                             const SizedBox(width: 38),
//                             const Icon(Icons.star, color: Colors.yellow),
//                             const SizedBox(width: 5),
//                             Text("${doctor.regNo ?? "0"}"),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
