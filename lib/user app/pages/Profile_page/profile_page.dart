import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_2.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_collect.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_collect.dart';
import 'package:health_hub/user%20app/pages/Profile_page/profile_photo_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_hub/main.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../../../Authentication/otp_verfication/phone_otp.dart';
import '../../../Backend_information/user_details_backend.dart';
import '../../../allfun.dart';

import 'dart:typed_data';

import '../../medicine_page/pages/add_address/add_another_address.dart';
import '../../medicine_page/pages/add_address/change_user_address.dart';

class profile_page extends StatefulWidget {
  const profile_page({super.key});

  @override
  State<profile_page> createState() => _profile_pageState();
}

class _profile_pageState extends State<profile_page> {
  // Future<bool> signOutFromGoogleAnd() async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //     // Remove the 'login' key to clear the logged-in state
  //     await prefs.remove('login');
  //     await FirebaseAuth.instance.signOut();
  //     await GoogleSignIn().signOut();
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => PhoneEntryPage()),
  //       (route) => false,
  //     );
  //
  //     return true;
  //   } catch (e) {
  //     print('Sign-out error: $e');
  //     return false;
  //   }
  // }
  //
  // Future<bool> signOutFromGoogleWeb(BuildContext context) async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.remove('login');
  //
  //     // Web: Revoke access and sign out completely
  //     await FirebaseAuth.instance.signOut();
  //     await GoogleSignIn().disconnect();
  //     await GoogleSignIn().signOut();
  //
  //     // Navigate to login screen
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => PhoneEntryPage()),
  //       (route) => false,
  //     );
  //
  //     return true;
  //   } catch (e) {
  //     print('Sign-out error (Web): $e');
  //     return false;
  //   }
  // }

  Future<void> logout(BuildContext context)async{
    showDialog(context: context, builder: (context)=>AlertDialog(
      content: Text("You want to logout ?",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Cancel",style: TextStyle(color: Colors.green),)),
            TextButton(onPressed: (){
              signOutFromphone(context);
            }, child: Text("Ok",style: TextStyle(color: Colors.red),))
          ],
        )
      ],
    ));
  }

  Future<bool> signOutFromphone(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the 'login' key to clear the logged-in state
      await prefs.remove('login');
      await prefs.remove('phone_number');
      await prefs.remove('address_id');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PhoneEntryPage()),
        (route) => false,
      );

      return true;
    } catch (e) {
      print('Sign-out error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:Scaffold(
          backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Color(0xfffdfdfd),
        title: text("Profile", Colors.black, 30, FontWeight.bold),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: Colors.black,)),
        actions: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                // onPressed: () {
                //   if (kIsWeb) {
                //     signOutFromGoogleWeb(context);
                //   } else {
                //     signOutFromGoogleAnd();
                //   }
                // },
                onPressed: () => logout(context),
                icon: Icon(
                  Icons.logout,
                  color: Color(0xff1f8acc),
                  size: 30,
                ),
              )),
        ],
      ),
      body: profile(),
    ));
  }
}

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  String phone_number = "";
  update_profile? userprofile;
  bool isloading = true;
  String? errormessage;
  Uint8List? webImage; // For storing image on Web

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user();


  }

  Future<void> user() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
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

  Widget menu_item(String text, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xffe5f4f1),
          child: Icon(icon, color: Color(0xff1f8acc)),
        ),
        title: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return userprofile != null
        ? ListView(
            children: [
              userprofile == null ||
                      userprofile!.firstName == null ||
                      userprofile!.lastName == null ||
                      userprofile!.age == null ||
                      userprofile!.email == null ||
                      userprofile!.gender == null
                  ? Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18.0, right: 18, bottom: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return SaveDetails();
                                });
                          },
                          child: Text(
                            "Create Profile",
                            style: TextStyle(
                                color: Color(0xff1f8acc), fontSize: 20),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(100, 50),
                            // Ensures the button is at least this size
                            padding: EdgeInsets.zero,
                            // Ensures no extra padding affects width
                            side: BorderSide(color: Color(0xff1f8acc)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                    ),

              Center(
                child: Stack(
                  children: [ 
                    Container(
                      // width: scc.width * 1,
                      // color: Colors.red,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20, top: 10, bottom: 20),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => pati_view(pati_views: userprofile!.userPhoto,)));
                              },
                              child:
                              CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                userprofile != null && userprofile!.userPhoto != null
                                    ? NetworkImage(
                                    "http://$ip:8000${userprofile!.userPhoto}")
                                    : NetworkImage('https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png')
                                as ImageProvider, // Use a default image
                              ) ,
                          )),
                    ),
                  ],
                ),
              ),
              isloading
                  ? Center(child: Text("guest"))
                  : userprofile?.firstName != null
                      ? Center(
                          child: Text(
                            "${userprofile!.firstName ?? ''} ${userprofile!.lastName ?? ''}",
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Center(
                          child: Text(
                              "Guest",
                            style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
              const SizedBox(height: 10),
              // Menu Items with Navigation
              menu_item('Personal details', CupertinoIcons.profile_circled, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              }),
              menu_item('Add Address', Icons.add, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const another_address()),
                );
              }),
              menu_item('Change Address', CupertinoIcons.cart, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const change_user_address()),
                );
              }),
              menu_item('Help', Icons.help_outline, () {}),
            ],
          )
        : Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
      height: 100,));
  }
}

