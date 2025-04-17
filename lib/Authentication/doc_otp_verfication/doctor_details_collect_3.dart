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
    SharedPreferences perf = await SharedPreferences.getInstance();
    perf.setString("speciality", specialty.text);
    perf.setString("service", service.text);
    perf.setString("qualification", qualification.text);
    perf.setString("bio", bio.text);
    perf.setString("reg_on", reg_on.text);
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("Notice!",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 25),),
      content: Text("Check your details correctly , can't change after create a account",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Cancel",style: TextStyle(color: Colors.red),)),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => doc_bio_photo()),
                );
              },

              child: Text("Ok", style: TextStyle(color: Colors.green)),
            ),

          ],
        )
      ],
    ));
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
              doc_form_field("reg_no", reg_on, TextInputType.number),
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
