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