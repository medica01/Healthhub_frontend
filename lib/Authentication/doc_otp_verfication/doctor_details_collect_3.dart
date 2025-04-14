import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Doctor app/doctor_homepage.dart';
import '../../Notification_services.dart';
import '../../allfun.dart';
import '../../main.dart';
import 'doctor_details_collect_2.dart';

class doc_bio extends StatefulWidget {
  const doc_bio({super.key});

  @override
  State<doc_bio> createState() => _doc_bioState();
}

class _doc_bioState extends State<doc_bio> {
  final TextEditingController specialty = TextEditingController();
  final TextEditingController service = TextEditingController();
  final TextEditingController qualification = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final TextEditingController reg_on = TextEditingController();
  String doc_phone_no = "";

  Future<void> _validandsave() async {
    List<String> missingfield = [];
    if (specialty.text.isEmpty) {
      missingfield.add("enter the medical field you well");
    }
    if (service.text.isEmpty ||
        int.parse(service.text) < 0 ||
        int.parse(service.text) > 47) {
      missingfield.add("enter your experience 1-47");
    }
    if (qualification.text.isEmpty) {
      missingfield.add("enter the qualification");
    }
    if (reg_on.text.isEmpty) {
      missingfield.add("enter the regno");
    }
    if (bio.text.isEmpty) {
      missingfield.add("enter the bio");
    }
    if (missingfield.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  "Missing field",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                content: Text(
                  "${missingfield.join("\n")}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Ok"))
                ],
              ));
    } else {
      if (missingfield.isEmpty) {
        _sensation_doc_details();
      }
    }
  }

  Future<void> _sensation_doc_details() async {
    String doc_first_name = "";
    String doc_last_name = "";
    String doc_age = "";
    String doc_email = "";
    String doc_language = "";
    String doc_location = "";
    String doc_gender = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    await perf.setBool('doc_login', true);
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no") ?? "";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
      doc_first_name = perf.getString("doc_first_name") ?? "";
      doc_last_name = perf.getString("doc_last_name") ?? "";
      doc_age = perf.getString("doc_age") ?? "";
      doc_email = perf.getString("doc_email") ?? "";
      doc_language = perf.getString("doc_language") ?? "";
      doc_location = perf.getString("doc_location") ?? "";
      doc_gender = perf.getString("doc_gender") ?? "";
    });
    try {
      final response = await http.post(
          Uri.parse("http://$ip:8000/doctor_details/doctor_addetails/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "doctor_name": "${doc_first_name}${doc_last_name}",
            "doctor_phone_no": doc_phone_no,
            "doctor_email": doc_email,
            "age": doc_age,
            "gender": doc_gender,
            "language": doc_language,
            "doctor_location": doc_location,
            "specialty": specialty.text,
            "service": service.text,
            "qualification": qualification.text,
            "bio": bio.text,
            "reg_no": reg_on.text
          }));
      if (response.statusCode == 201) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Notice",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    "Please check all the details or correct ?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => doc_bio_photo()));
                            },
                            child: Text(
                              "Ok",
                              style: TextStyle(color: Colors.green),
                            )),
                      ],
                    )
                  ],
                ));
        NotificationService().showNotification(id: 0, title: "Health Hub", body: "thanking doctor for Joining Health hub");
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Update error",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    "Could not reach the server",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("ok"))
                  ],
                ));
      }
    } catch (e) {
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "sensational data only for developer",
          style: TextStyle(color: Color(0xff1f8acc)),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // color: Colors.red,
              border: Border.all(color: Colors.black, width: 2)),
          height: 500,
          width: 350,
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // doc_form_field
              doc_form_field("enter Specialty", specialty, TextInputType.text),
              doc_form_field("enter service", service, TextInputType.number),
              doc_form_field(
                  "enter qualification", qualification, TextInputType.text),
              doc_form_field("reg_no", reg_on, TextInputType.text),
              Padding(
                padding:
                    EdgeInsets.only(top: 8.0, bottom: 8, left: 13, right: 13),
                child: TextField(
                  cursorColor: Color(0xff1f8acc),
                  style: TextStyle(
                      color: Color(0xff1f8acc), fontWeight: FontWeight.bold),
                  controller: bio,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    focusColor: Color(0xff1f8acc),
                    counterText: '',
                    alignLabelWithHint: true,
                    hintText: 'bio',
                    hintStyle: TextStyle(
                      color: Color(0xff1f8acc),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0), // Focused border color
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 8.0, bottom: 8, left: 13, right: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          specialty.clear();
                          service.clear();
                          qualification.clear();
                          reg_on.clear();
                          bio.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xff1f8acc)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: SizedBox(
                          width: 80,
                          height: 40,
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xff1f8acc),
                              ),
                            ),
                          ),
                        )),
                    OutlinedButton(
                        onPressed: () => _validandsave(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xff1f8acc),
                          side: BorderSide(color: Color(0xff1f8acc)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: SizedBox(
                          width: 80,
                          height: 40,
                          child: Center(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
