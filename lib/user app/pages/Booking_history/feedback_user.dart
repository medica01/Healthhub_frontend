import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class feed_doctor extends StatefulWidget {
  const feed_doctor({super.key});

  @override
  State<feed_doctor> createState() => _feed_doctorState();
}

class _feed_doctorState extends State<feed_doctor> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userpro();
  }
  TextEditingController feed=TextEditingController();
  update_profile? userprofile;
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
          // isLoading = false;
        });
      } else {
        setState(() {
          // errorMessage = response.body.toString();
          // isLoading = false;
        });
      }
    } catch (e) {
      // errorMessage = e.toString();
      // isLoading = false;
    }
  }
  Future<void> postfee()async{
    try{
      final response = await http.post(Uri.parse("http://$ip:8000/chats/feeeed/"),
          headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_name":"${userprofile!.firstName} ${userprofile!.lastName}",
          "feedback": feed.text
        })
      );
      if(response.statusCode==201){
        print("feed backed added successfully");
      }
    }catch(e){}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              TextField(
                cursorColor: Color(0xff1f8acc),
                style: TextStyle(
                    color: Color(0xff1f8acc), fontWeight: FontWeight.bold),
                controller: feed,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  focusColor: Color(0xff1f8acc),
                  counterText: '',
                  alignLabelWithHint: true,
                  hintText: 'your valuable feed back',
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
              OutlinedButton(onPressed: (){
                postfee();
              }, child: Text("feed back"))
            ],
          ),
        ),
      ),
    );
  }
}
