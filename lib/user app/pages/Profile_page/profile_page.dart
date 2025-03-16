import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_2.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_collect.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_collect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_hub/main.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../../../Authentication/otp_verfication/phone_otp.dart';
import '../../../Backend_information/user_details_backend.dart';
import '../../../allfun.dart';

import 'dart:typed_data';

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

  Future<bool> signOutFromphone(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the 'login' key to clear the logged-in state
      await prefs.remove('login');

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfffdfdfd),
        title: text("Profile", Colors.black, 30, FontWeight.bold),
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
                onPressed: () => signOutFromphone(context),
                icon: Icon(
                  Icons.logout,
                  color: Color(0xff1f8acc),
                  size: 30,
                ),
              )),
        ],
      ),
      body: profile(),
    );
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
  io.File? img;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user();

    _loadimg();
  }

  // Future<void> _pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   if (image != null) {
  //     if (kIsWeb) {
  //       // Web: Convert XFile to Uint8List
  //       final bytes = await image.readAsBytes();
  //       setState(() {
  //         webImage = bytes;
  //         // print("$webImage");// Save bytes instead of File
  //       });
  //       await _updateuserphoto();
  //       // _saveimg(webImage.path);
  //     } else {
  //       // Mobile: Use File
  //       setState(() {
  //         img = File(image.path);
  //       });
  //       _saveimg(image.path); // Save path only for mobile
  //     }
  //   }
  // }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImage = bytes;
        });
        // _saveimg(webImage as String);
        await _updateuserphoto();
      } else {
        // For Mobile
        setState(() {
          img = io.File(pickedFile.path);
        });
        // _saveimg(img as String);
        await _updateuserphoto();
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _saveimg(String imag) async {
    SharedPreferences prg = await SharedPreferences.getInstance();
    await prg.setString("image_path", imag);
  }

  Future<void> _loadimg() async {
    SharedPreferences perff = await SharedPreferences.getInstance();
    String? imagepath = perff.getString("image_path");
    if (imagepath != null) {
      setState(() {
        img = File(imagepath);
      });
    }
  }

  Future<void> _updateuserphoto() async {
    // String? web_img = webImage as String?;
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    final String uploadUrl =
        'http://$ip:8000/user_profile/user_edit/$phone_number/';
    if (kIsWeb && webImage != null) {
      // Web upload
      var request = http.MultipartRequest('PUT', Uri.parse(uploadUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'user_photo',
        webImage!,
        filename: 'upload.png', // Adjust the filename as needed
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else if (!kIsWeb && img != null) {
      // Mobile upload
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'user_photo',
        img!.path,
        filename: basename(img!.path),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else {
      print('No image to upload.');
    }
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
                      height: 2,
                    ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                indent: 5,
                endIndent: 5,
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
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => photo()));
                              },
                              child:
                              // Container(
                              //   width: 130,
                              //   height: 130,
                              //   decoration: BoxDecoration(
                              //     boxShadow: [
                              //       BoxShadow(
                              //           color: Colors.grey,
                              //           offset: Offset(0, 2),
                              //           blurRadius: 12)
                              //     ],
                              //     shape: BoxShape.circle,
                              //     image: DecorationImage(
                              //       image: img != null
                              //           ? FileImage(img!) // For Mobile (File)
                              //           : webImage != null
                              //               ? MemoryImage(
                              //                   webImage!) // For Web (Uint8List)
                              //               : AssetImage("assetName"),
                              //       fit: BoxFit.cover,
                              //     ),
                              //   ),
                              // ),
                              CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                userprofile != null && userprofile!.userPhoto != null
                                    ? NetworkImage(
                                    "http://$ip:8000${userprofile!.userPhoto}")
                                    : AssetImage('assets/default_avatar.png')
                                as ImageProvider, // Use a default image
                              ) ,
                          )),
                    ),
                    // Positioned(
                    //   right: 13,
                    //   bottom: 20,
                    //   child: Container(
                    //     height: 40,
                    //     width: 40,
                    //     decoration: BoxDecoration(
                    //         color: Colors.white.withOpacity(0.65),
                    //         shape: BoxShape.circle),
                    //     child: IconButton(
                    //         onPressed: _pickImage,
                    //         icon: Icon(
                    //           Icons.camera_alt,
                    //         )),
                    //   ),
                    // ),
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
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        ),
              const SizedBox(height: 10),
              // Menu Items with Navigation
              menu_item('Personal details', CupertinoIcons.profile_circled, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => personal_details()),
                );
              }),
              menu_item('Settings', Icons.settings, () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const ProfileDetailsPage()),
                // );
              }),
              menu_item('About', CupertinoIcons.info, () {}),
              menu_item('Help', Icons.help_outline, () {}),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

