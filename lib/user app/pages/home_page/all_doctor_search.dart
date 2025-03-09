// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Backend_information/Backend_doctor_details.dart';
// import '../../../main.dart';
// import 'doctor_profile_3.dart';
//
// class search_doctor extends StatefulWidget {
//   const search_doctor({super.key});
//
//   @override
//   State<search_doctor> createState() => _search_doctorState();
// }
//
// class _search_doctorState extends State<search_doctor> {
//   bool set_fav = false;
//   String doc_id = "";
//   // bool isLoading = false;
//   TextEditingController search = TextEditingController();
//   List<doctor_details> search_doctor = [];
//   String errorMessage ="";
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _search_doc_get();
//   }
//
//   Future<void> _search_doc_get() async {
//     // String search_d = search.text;
//     final url = Uri.parse("http://$ip:8000/doctor_details/doctor_search/?q=gokul");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         List<dynamic> jsonResponse = jsonDecode(response.body);
//         print("jsonResponse : $jsonResponse");
//         print("response.body :${response.body}");
//         var resultList = jsonResponse['result'];
//         if (resultList is List){
//           setState(() {
//             search_doctor = resultList
//                 .map((data) => doctor_details.fromJson(data))
//                 .toList();
//             print("$search_doctor");
//             // isLoading = true;
//           });
//         }
//       } else {
//         setState(() {
//           errorMessage = "failed to load doctor_details";
//           // isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         // isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _favorite_doctor() async {
//     String phone_number = "";
//     SharedPreferences perf = await SharedPreferences.getInstance();
//     setState(() {
//       phone_number = perf.getString('phone_number') ?? "917845711277";
//       phone_number = phone_number.replaceFirst('+', '');
//     });
//     try {
//       final response = await http.post(
//           Uri.parse("http://$ip:8000/booking_doctor/create_favorite_doc/"),
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode(
//               {"id": doc_id, "like": set_fav, "phone_number": phone_number}));
//       if (response.statusCode == 201) {
//         showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//                   title: Text(
//                     "your like add",
//                     style: TextStyle(
//                         color: Colors.green,
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   content: Text("this doctor is like by you."),
//                 ));
//       } else {
//         showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//                   title: Text(
//                     "Alert",
//                     style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   content: Text(
//                     "This Doctor already marked as a favorite",
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   actions: [
//                     TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         child: Text(
//                           "OK",
//                           style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 25,
//                               fontWeight: FontWeight.bold),
//                         ))
//                   ],
//                 ));
//       }
//     } catch (e) {
//       showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//                 title: Text(
//                   "Alert",
//                   style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 content: Text("$e"),
//                 actions: [
//                   TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text("ok"))
//                 ],
//               ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Container(
//           height: 35,
//           width: 240,
//           child: SearchBar(
//             leading: Icon(Icons.search),
//             controller: search,
//             hintText: 'Search',
//             backgroundColor: WidgetStatePropertyAll(Colors.white),
//             shadowColor: WidgetStatePropertyAll(Colors.grey),
//             elevation: WidgetStatePropertyAll(6.0),
//             shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(40))),
//             padding:
//                 WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16.0)),
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _search_doc_get();
//             },
//             icon: Icon(Icons.search_rounded),
//             color: Color(0xff0a8eac),
//           )
//         ],
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 10.0),
//             child: ListView.builder(
//                 physics: BouncingScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: search_doctor.length,
//                 itemBuilder: (context, index) {
//                   var doctor = search_doctor[index];
//                   return doctor.id !=null
//                       ? Padding(
//                           padding: EdgeInsets.only(
//                               left: 13.0, right: 13, bottom: 15),
//                           child: Card(
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             clipBehavior: Clip.hardEdge,
//                             shadowColor: Colors.grey,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 // borderRadius: BorderRadius.circular(40),
//                               ),
//                               height: 190,
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 10.0, top: 15, bottom: 15),
//                                 child: Center(
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 40,
//                                         backgroundImage: NetworkImage(
//                                           // scale: 10,
//                                           doctor.doctorImage != null
//                                               ? "http://$ip:8000${doctor.doctorImage}"
//                                               : "no data ",
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.only(left: 18.0),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   "${doctor.doctorName}",
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 20),
//                                                 ),
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           left: 28.0),
//                                                   child: IconButton(
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         doc_id = search_doctor[
//                                                                     index]
//                                                                 .id
//                                                                 ?.toString() ??
//                                                             '';
//                                                         search_doctor[index]
//                                                                 .like =
//                                                             !(search_doctor[
//                                                                         index]
//                                                                     .like ??
//                                                                 false);
//                                                         set_fav =
//                                                             search_doctor[index]
//                                                                 .like!;
//                                                         print(
//                                                             "${search_doctor[index].id}");
//                                                         _favorite_doctor();
//                                                         // _add_like_doctor_details();
//                                                       });
//                                                     },
//                                                     icon: Icon(
//                                                       (set_fav ?? false)
//                                                           ? FontAwesomeIcons
//                                                               .solidHeart
//                                                           : FontAwesomeIcons
//                                                               .heart,
//                                                       color:
//                                                           (search_doctor[index]
//                                                                       .like ??
//                                                                   false)
//                                                               ? Colors.red
//                                                               : Colors.grey,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   EdgeInsets.only(bottom: 5.0),
//                                               child: Text(
//                                                 "${doctor.specialty}",
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   EdgeInsets.only(bottom: 5.0),
//                                               child: Text(
//                                                 "${doctor.service} years of exp",
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ),
//                                             // Padding(
//                                             //   padding: EdgeInsets.only(bottom: 5.0),
//                                             //   child: Text(
//                                             //     doctor.language ?? "english",
//                                             //     style: TextStyle(
//                                             //       fontSize: 14,
//                                             //     ),
//                                             //   ),
//                                             // ),
//                                             // Padding(
//                                             //   padding: EdgeInsets.only(bottom: 5.0),
//                                             //   child: Text(
//                                             //     doctor.doctorLocation ??
//                                             //         "No specility",
//                                             //     style: TextStyle(
//                                             //       fontSize: 14,
//                                             //     ),
//                                             //   ),
//                                             // ),
//
//                                             Padding(
//                                               padding:
//                                                   EdgeInsets.only(top: 8.0),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 children: [
//                                                   OutlinedButton(
//                                                       onPressed: () {
//                                                         Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                                 builder:
//                                                                     (context) =>
//                                                                         doc_profile(
//                                                                           data:
//                                                                               "${doctor.id}",
//                                                                         )));
//                                                       },
//                                                       style: OutlinedButton
//                                                           .styleFrom(
//                                                               backgroundColor:
//                                                                   Colors
//                                                                       .blueAccent,
//                                                               shadowColor:
//                                                                   Colors.grey),
//                                                       child: Text(
//                                                         "Book",
//                                                         style: TextStyle(
//                                                             color:
//                                                                 Colors.white),
//                                                       )),
//                                                   Padding(
//                                                     padding: EdgeInsets.only(
//                                                         left: 38.0),
//                                                     child: Row(
//                                                       children: [
//                                                         Icon(
//                                                           Icons.star,
//                                                           color: Colors.yellow,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   Container(
//                                                       width: 60,
//                                                       child: Text(
//                                                           "${doctor.regNo ?? 0}")),
//                                                 ],
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                       : Text("no data");
//                 }),
//           ),
//           Container(
//             height: 100,
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'doctor_profile_3.dart';

class SearchDoctorPage extends StatefulWidget {
  @override
  _SearchDoctorPageState createState() => _SearchDoctorPageState();
}

class _SearchDoctorPageState extends State<SearchDoctorPage> {
  TextEditingController searchController = TextEditingController();
  List<doctor_details> search_doctor = [];
  bool isLoading = false;
  bool set_fav = false;
  String doc_id = "";

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
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "your like add",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
              content: Text("this doctor is like by you."),
            ));
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
      appBar: AppBar(title: Text("Search Doctor")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.only(top: 8.0,bottom: 14,left: 13,right: 13),
              child: TextField(
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
                  if (query.length > 2) {
                    searchDoctors(query);
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: search_doctor.isEmpty
                  ? Center(child: Text("No doctors found"))
                  : ListView.builder(
                itemCount: search_doctor.length,
                itemBuilder: (context, index) {
                  var doctor = search_doctor[index];
                  return doctor.id !=null
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
                          child: Center(
                            child: Row(
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
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  doc_id = search_doctor[
                                                  index]
                                                      .id
                                                      ?.toString() ??
                                                      '';
                                                  search_doctor[index]
                                                      .like =
                                                  !(search_doctor[
                                                  index]
                                                      .like ??
                                                      false);
                                                  set_fav =
                                                  search_doctor[index]
                                                      .like!;
                                                  print(
                                                      "${search_doctor[index].id}");
                                                  _favorite_doctor();
                                                  // _add_like_doctor_details();
                                                });
                                              },
                                              icon: Icon(
                                                (set_fav ?? false)
                                                    ? FontAwesomeIcons
                                                    .solidHeart
                                                    : FontAwesomeIcons
                                                    .heart,
                                                color:
                                                (search_doctor[index]
                                                    .like ??
                                                    false)
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
                      : Text("no data");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}