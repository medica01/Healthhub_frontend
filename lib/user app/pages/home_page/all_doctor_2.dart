import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/pages/home_page/doctor_profile_3.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../../Backend_doctor_details.dart';


class all_doctor extends StatefulWidget {
  const all_doctor({super.key});

  @override
  State<all_doctor> createState() => _all_doctorState();
}

class _all_doctorState extends State<all_doctor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "All Doctor",
          style:
              TextStyle(color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(
              left: 10.0,
            ),
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  width: 360,
                  child: SearchBar(
                    leading: Icon(Icons.search),
                    hintText: 'Search a Doctor',

                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    // shadowColor: WidgetStatePropertyAll(Colors.grey),
                    elevation: WidgetStatePropertyAll(6.0),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                  ),
                )),
          ),
        ),
      ),
      body: doctor_id(),
    );
  }
}

class doctor_id extends StatefulWidget {
  const doctor_id({super.key});

  @override
  State<doctor_id> createState() => _doctor_idState();
}

class _doctor_idState extends State<doctor_id> {
  bool heart = false;
  List<doctor_details> doctor_detail = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _showdoctor1();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: doctor_detail.length,
          itemBuilder: (context, index) {
            var doctor = doctor_detail[index];
            return doctor.id != null
                ? Padding(
                    padding: EdgeInsets.only(left: 13.0, right: 13, bottom: 15),
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
                          // borderRadius: BorderRadius.circular(40),
                        ),
                        height: 190,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10.0, top: 15, bottom: 15),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${doctor.doctorName ?? "unknown"}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 28.0),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  heart = !heart;
                                                });
                                              },
                                              icon: Icon(
                                                heart
                                                    ? FontAwesomeIcons.solidHeart
                                                    : FontAwesomeIcons.heart,
                                                color: heart
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          doctor.specialty ?? "No specility",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          "${doctor.service ?? "No service"} years of exp",
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
                                                          builder: (context) =>
                                                              doc_profile(
                                                                data:
                                                                    "${doctor.id}",
                                                              )));
                                                },
                                                style: OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                    shadowColor: Colors.grey),
                                                child: Text(
                                                  "Book",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 38.0),
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
                                                child:
                                                    Text("${doctor.regNo ?? 0}")),
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
    );
  }
}
