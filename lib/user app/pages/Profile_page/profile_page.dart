import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_2.dart';
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

  Future<bool> signOutFromphone() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the 'login' key to clear the logged-in state
      await prefs.remove('login');

      Navigator.pushAndRemoveUntil(
        context as BuildContext,
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
                onPressed: () => signOutFromphone(),
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
        await _updateuserphoto();
      } else {
        // For Mobile
        setState(() {
          img = io.File(pickedFile.path);
          // _saveimg(img);
        });
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
    final String uploadUrl = 'http://$ip:8000/user_profile/user_edit/$phone_number/';
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
    return ListView(
      children: [
        userprofile == null ||
                userprofile!.firstName == null ||
                userprofile!.lastName == null ||
                userprofile!.age == null ||
                userprofile!.email == null ||
                userprofile!.gender == null
            ? Container(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 18.0, right: 18, bottom: 10),
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
                      style: TextStyle(color: Color(0xff1f8acc), fontSize: 20),
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
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0, 2),
                                blurRadius: 12)
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(

                            image: img != null
                                ? FileImage(img!) // For Mobile (File)
                                : webImage != null
                                ? MemoryImage(webImage!) // For Web (Uint8List)
                                : AssetImage('assets/placeholder.png') as ImageProvider, // Placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                  )
                  ),
              ),
              Positioned(
                right: 13,
                bottom: 20,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      shape: BoxShape.circle),
                  child: IconButton(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.camera_alt,
                      )),
                ),
              ),
            ],
          ),
        ),
        isloading
            ? Center(child: Text("guest"))
            : userprofile != null
                ? Center(
                    child: Text(
                      "${userprofile!.firstName ?? ''} ${userprofile!.lastName ?? ''}",
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                  )
                : Center(
                    child: Text(
                      errormessage ?? "Guest",
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
    );
  }
}

class SaveDetails extends StatefulWidget {
  const SaveDetails({super.key});

  @override
  State<SaveDetails> createState() => _SaveDetailsState();
}

class _SaveDetailsState extends State<SaveDetails> {
  final _form = GlobalKey<FormState>();
  final List<String> genders = ["Male", "Female", "Other"];
  int selectedGenderIndex = -1; // Default gender is "Male"
  final TextEditingController firstnamecontroller = TextEditingController();
  final TextEditingController lastnamecontroller = TextEditingController();
  final TextEditingController agecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  String phone_number = "";

  Future<void> _updateuser() async {
    String first_name = firstnamecontroller.text;
    String last_name = lastnamecontroller.text;
    String age = agecontroller.text;
    String gender = genders[selectedGenderIndex];
    String email = emailcontroller.text;
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.put(
          Uri.parse('http://$ip:8000/user_profile/user_edit/$phone_number/'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'first_name': first_name,
            'last_name': last_name,
            'gender': gender,
            'age': age,
            'email': email
          }));

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pushAndRemoveUntil(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => profile_page()),
          (route) => false,
        );
      } else {
        print('update user details failed:${response.body}');
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
              content: Text("Update user details failed: ${response.body}")),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  void _validateandsave() {
    List<String> missingfields = [];
    if (firstnamecontroller.text.isEmpty) {
      missingfields.add("enter first name");
    }
    if (lastnamecontroller.text.isEmpty) {
      missingfields.add("enter last name");
    }
    if (agecontroller.text.isEmpty) {
      missingfields.add("enter age correctly");
    }
    if (emailcontroller.text.isEmpty) {
      missingfields.add("enter email id");
    }
    if (selectedGenderIndex == -1) {
      missingfields.add("select the gender");
    }

    if (missingfields.isNotEmpty) {
      showDialog(
          context: context as BuildContext,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Missing Fields",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                content: Text("${missingfields.join("\n")}"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Color(0xff1f8acc)),
                    ),
                  ),
                ],
              ));
    } else {
      if (missingfields.isEmpty) {
        _updateuser();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait mode for this page
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Reset orientation to allow rotation when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    firstnamecontroller.dispose();
    lastnamecontroller.dispose();
    agecontroller.dispose();
    emailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scr = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        height: 720, // Adjusted height to fit the new gender feature
        width: scr.width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              spreadRadius: 300,
              color: Colors.grey.withOpacity(0.7),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Add User Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 25,
                endIndent: 35,
              ),
              // First Name Field
              Flexible(
                child: textfielld2(
                  Colors.grey.withOpacity(0.2),
                  Colors.grey.withOpacity(0.6),
                  const Color(0xff1f8acc),
                  BorderRadius.circular(30),
                  const EdgeInsets.all(20),
                  30,
                  10,
                  "Enter the first name",
                  firstnamecontroller,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: textfielld2(
                      Colors.grey.withOpacity(0.2),
                      Colors.grey.withOpacity(0.6),
                      const Color(0xff1f8acc),
                      BorderRadius.circular(30),
                      const EdgeInsets.all(20),
                      30,
                      10,
                      "Enter the last name",
                      lastnamecontroller),
                ),
              ),
              // Age Field
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 28.0),
                      child: Text(
                        "Age:",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff1f8acc),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextFormField(
                          controller: agecontroller,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.blue.withOpacity(0.5)),
                          cursorColor: Colors.blue,
                          maxLength: 3,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          // validator: (value) {
                          //
                          //   int? age = int.tryParse(value!);
                          //   if (age == null || age > 100) {
                          //     return "Enter age (1-100)";
                          //   }
                          //   return null;
                          // },
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "Enter the age",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.6),
                            ),
                            contentPadding: const EdgeInsets.all(20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, bottom: 10),
                child: Text(
                  "Gender:",
                  style: TextStyle(color: Color(0xff1f8acc), fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    genders.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGenderIndex = index;
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedGenderIndex == index
                              ? Color(0xff1f8acc)
                              : Colors.transparent,
                          border: Border.all(
                            color: Color(0xff1f8acc),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            genders[index],
                            style: TextStyle(
                              color: selectedGenderIndex == index
                                  ? Colors.white
                                  : Color(0xff1f8acc),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: textfielld2(
                      Colors.grey.withOpacity(0.2),
                      Colors.grey.withOpacity(0.6),
                      const Color(0xff1f8acc),
                      BorderRadius.circular(30),
                      const EdgeInsets.all(20),
                      30,
                      10,
                      "Enter your Email",
                      emailcontroller),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 28.0, bottom: 20),
                child: Container(
                  width: 335,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            firstnamecontroller.clear();
                            lastnamecontroller.clear();
                            agecontroller.clear();
                            emailcontroller.clear();
                            setState(() {
                              selectedGenderIndex = -1;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Color(0xff1f8acc)), // Set border color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(40), // Rounded corners
                            ),
                          ),
                          child: SizedBox(
                            width: 100,
                            height: 40, // Set the desired width
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Color(0xff1f8acc),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ), // Ensure text is centered
                            ),
                          )),
                      GestureDetector(
                        onTap: () {
                          _validateandsave();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Color(0xff1f8acc),
                                borderRadius: BorderRadius.circular(40)),
                            child: SizedBox(
                              width: 150,
                              height: 40, // Set the desired width
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ), // Ensure text is centered
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
