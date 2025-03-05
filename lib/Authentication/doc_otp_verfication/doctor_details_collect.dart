import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../allfun.dart';
import '../../main.dart';
import 'doctor_details_collect_2.dart';

class doc_details_col extends StatefulWidget {
  const doc_details_col({super.key});

  @override
  State<doc_details_col> createState() => _doc_details_colState();
}

class _doc_details_colState extends State<doc_details_col> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: doc_det_collect(),
    );
  }
}

class doc_det_collect extends StatefulWidget {
  const doc_det_collect({super.key});

  @override
  State<doc_det_collect> createState() => _doc_det_collectState();
}

class _doc_det_collectState extends State<doc_det_collect> {
  final TextEditingController first_name = TextEditingController();
  final TextEditingController last_name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController language = TextEditingController();
  final TextEditingController location = TextEditingController();
  final List<String> gender = ["male", "female", "other"];
  int selectgender = -1;
  String doc_phone_no ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    first_name.dispose();
    last_name.dispose();
    age.dispose();
    email.dispose();
    language.dispose();
    location.dispose();
  }

  void _validateandsave() {
    List<String> missingfield = [];
    if (first_name.text.isEmpty) {
      missingfield.add("enter the first name");
    }
    if (last_name.text.isEmpty) {
      missingfield.add("enter the last name");
    }
    if (email.text.isEmpty) {
      missingfield.add("enter the email");
    }
    if (age.text.isEmpty || int.tryParse(age.text) == null ||int.parse(age.text)<23|| int.parse(age.text) > 100) {
      missingfield.add("Enter a valid age (23-100)");
    }

    if (language.text.isEmpty) {
      missingfield.add("enter the language");
    }
    if (location.text.isEmpty) {
      missingfield.add("enter the location");
    }
    if (selectgender == -1) {
      missingfield.add("select the gender");
    }
    if (missingfield.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Missing field",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 25),
                ),
                content: Text("${missingfield.join("\n")}"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Color(0xff1f8acc)),
                      ))
                ],
              ));
    } else {
      if (missingfield.isEmpty) {
        _update_doc();
      }
    }
  }

  Future<void> _update_doc() async{
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no= perf.getString("doctor_phone_no") ?? "";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
    });
    try{
      final response  = await http.put(Uri.parse("http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "doctor_name": "${first_name.text} ${last_name.text}",
          "doctor_email": email.text,
          "age": age.text,
          "gender": gender[selectgender],
          "language": language.text,
          "doctor_location": location.text,
        })
      );
      if(response.statusCode == 200 || response.statusCode == 204){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_bio_photo()));
      }else{
        showDialog(context: context, builder: (context)=>AlertDialog(
          title: Text("Update error",style: TextStyle(color: Colors.red,fontSize: 25,fontWeight: FontWeight.bold),),
          content: Text("Could not reach the server",style: TextStyle(fontWeight: FontWeight.bold),),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("ok"))
          ],
        ));
      }
    }catch(e){}
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Flexible(
        child: Container(
          height: screen.height * 0.89,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Container(
                clipBehavior: Clip.hardEdge,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.black, width: 2),
                  // color: Colors.red,
                ),
                child: Form(
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Center(
                            child: Text(
                              "fill the details",
                              style: TextStyle(
                                  color: Color(0xff1f8acc),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          doc_form_field("First name", first_name,TextInputType.text),
                          doc_form_field("Last name", last_name,TextInputType.text),
                          doc_form_field("Email", email,TextInputType.emailAddress),
                          doc_form_field("Age", age,TextInputType.number),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, bottom: 10),
                            child: Text(
                              "Gender:",
                              style: TextStyle(
                                  color: Color(0xff1f8acc), fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                gender.length,
                                (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectgender = index;
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Container(
                                          height: 50,
                                          width: 75,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                              color: selectgender == index
                                                  ? Color(0xff1f8acc)
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: Color(0xff1f8acc),
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Center(
                                            child: Text(
                                              gender[index],
                                              style: TextStyle(
                                                  color: selectgender == index
                                                      ? Colors.white
                                                      : Color(0xff1f8acc),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                          ),
                          doc_form_field("Known Language", language,TextInputType.text),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 8.0, bottom: 8, left: 13, right: 13),
                            child: TextField(
                              cursorColor: Color(0xff1f8acc),
                              style: TextStyle(
                                  color: Color(0xff1f8acc),
                                  fontWeight: FontWeight.bold),
                              controller: location,
                              maxLines: 2,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                focusColor: Color(0xff1f8acc),
                                counterText: '',
                                alignLabelWithHint: true,
                                hintText: 'Location',
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
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8.0, bottom: 8, left: 13, right: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  first_name.clear();
                                  last_name.clear();
                                  age.clear();
                                  email.clear();
                                  language.clear();
                                  location.clear();
                                  setState(() {
                                    selectgender =-1;
                                  });
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
                                onPressed: ()=>
                                  _validateandsave(),

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
            ),
          ),
        ),
      ),
    );
  }
}
