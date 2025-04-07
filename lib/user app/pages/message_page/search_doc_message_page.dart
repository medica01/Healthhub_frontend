import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart%20' as http;

import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../main.dart';
import 'chatting_user_to_doc_2.dart';


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
              child:
              AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  horizontalOffset: 500.0,
                  child: FadeInAnimation(
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
                  ),
                ),
              )

            )
                : Text("data");
          }),
    );
  }
}
