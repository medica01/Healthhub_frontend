import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/allfun.dart';
import 'package:health_hub/user%20app/pages/Profile_page/profile_photo_2.dart';
import 'package:http/http.dart%20' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  update_profile? userprofile;
  bool isloading = true;
  String errormessage = "";

  void initState() {
    super.initState();
    user();
  }

  Future<void> user() async {
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "";
      phone_number = phone_number.replaceFirst('+', '');
    });
    final url =
        Uri.parse("http://$ip:8000/user_profile/user_edit/$phone_number/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          userprofile = update_profile.fromJson(jsonResponse);
          isloading = false;
        });
      } else {
        setState(() {
          errormessage = "failed to load user details";
          isloading = false;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      isloading = false;
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
      body: !isloading
          ? ListView(
              children: [
                Container(
                  height: 750,

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
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>pati_view(pati_views: userprofile!.userPhoto,)));
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: userprofile != null &&
                                      userprofile!.userPhoto != null
                                  ? NetworkImage(
                                      "http://$ip:8000${userprofile!.userPhoto}")
                                  : NetworkImage(
                                          'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        profileField("Full Name",
                            "${userprofile!.firstName} ${userprofile!.lastName}"),
                        profileField(
                            "Phone Number", "+${userprofile!.phoneNumber}"),
                        profileField("Email", "${userprofile!.email}"),
                        profileField("age", "${userprofile!.age}"),
                        profileField("Gender", "${userprofile!.gender}"),
                        SizedBox(height: 20),
                        // Center(
                        //   child: ElevatedButton(
                        //     onPressed: () async {
                        //       final result = await Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => EditProfileScreen(
                        //             name: name,
                        //             phone: phone,
                        //             email: email,
                        //             dob: dob,
                        //           ),
                        //         ),
                        //       );
                        //
                        //       if (result != null) {
                        //         setState(() {
                        //           name = result['name'];
                        //           phone = result['phone'];
                        //           email = result['email'];
                        //           dob = result['dob'];
                        //         });
                        //       }
                        //     },
                        //     child: Text("Update Profile"),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
        height: 100,))
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
