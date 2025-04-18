import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart%20' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../main.dart';
import 'doc_photo_view.dart';

class doc_personal extends StatefulWidget {
  const doc_personal({super.key});

  @override
  State<doc_personal> createState() => _doc_personalState();
}

class _doc_personalState extends State<doc_personal> {
  String errormessage = "";
  doctor_details? _get_doc_details;
  String doc_phone_no = "";
  bool isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_doctor_details();
  }

  Future<void> _get_doctor_details() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no") ?? "";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
      print("$doc_phone_no");
    });
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _get_doc_details = doctor_details.fromJson(jsonResponse);
          isloading = true;
        });
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent.shade200,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isloading
          ? ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.white54],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_view(doc_photo: _get_doc_details!.doctorImage,)));
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _get_doc_details != null &&
                                      _get_doc_details!.doctorImage != null
                                  ? NetworkImage(
                                      "http://$ip:8000${_get_doc_details!.doctorImage}")
                                  : NetworkImage(
                                          'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        profileField(
                            "Full Name", "${_get_doc_details!.doctorName}"),
                        profileField("Phone Number",
                            "+${_get_doc_details!.doctorPhoneNo}"),
                        profileField("age", "${_get_doc_details!.age}"),
                        profileField("Gender", "${_get_doc_details!.gender}"),
                        profileField("Qualification",
                            "${_get_doc_details!.qualification}"),
                        profileField(
                            "Specialist", "${_get_doc_details!.specialty}"),
                        profileField("Service", "${_get_doc_details!.service}"),
                        profileField(
                            "Email", "${_get_doc_details!.doctorEmail}"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget profileField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(value, style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
