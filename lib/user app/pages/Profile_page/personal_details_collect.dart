import 'dart:convert';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_hub/Notification_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_hub/user%20app/pages/Profile_page/profile_page.dart';
import 'package:health_hub/user%20app/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../allfun.dart';
import '../../../main.dart';
import '../home_page/hoem_page.dart';

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
  final TextEditingController addresscontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  String phone_number = "";
  String email ="";

  Future<void> updateuser(BuildContext context) async {
    String first_name = firstnamecontroller.text;
    String last_name = lastnamecontroller.text;
    String age = agecontroller.text;
    String gender = genders[selectedGenderIndex];
    String address = addresscontroller.text;

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("first_name", first_name);
    pref.setString("last_name", last_name);
    pref.setString("age", age);
    pref.setString("gender", gender);
    pref.setString("address", address);
    print("user data save successfully");
    Navigator.pop(context);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return user_photo();
        });
  }

  void _validateandsave(BuildContext context) {
    List<String> missingfields = [];
    if (firstnamecontroller.text.isEmpty) {
      missingfields.add("enter first name");
    }
    if (lastnamecontroller.text.isEmpty) {
      missingfields.add("enter last name");
    }
    if (agecontroller.text.isEmpty|| int.parse(agecontroller.text)<3|| int.parse(agecontroller.text) > 100) {
      missingfields.add("enter age correctly");
    }
    if (email=="") {
      missingfields.add("enter email id");
    }
    if (addresscontroller.text=="") {
      missingfields.add("enter your address");
    }
    if (selectedGenderIndex == -1) {
      missingfields.add("select the gender");
    }

    if (missingfields.isNotEmpty) {
      showDialog(
          context: context,
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
        updateuser(context);
      }
    }
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
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Load email from SharedPreferences when the widget is initialized
    // _loadEmail();
  }

  // Load email from SharedPreferences
  Future<void> _loadEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      email = pref.getString("email") ?? "";
    });
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        // Web-specific sign-in method
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

        await saveUserData(userCredential.user);

        return userCredential.user;
      } else {
        // Android-specific sign-in method
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Save user data to Firestore
        await saveUserData(userCredential.user);

        return userCredential.user;
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> saveUserData(User? user) async {
    if (user != null && user.email != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("email", user.email!);
      // Update the local state to trigger UI rebuild
      setState(() {

        email = user.email!;
      });
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      if (kIsWeb) {
        // Web-specific sign-out
        await FirebaseAuth.instance.signOut();
      } else {
        // Android-specific sign-out
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
      }
      // Clear email from SharedPreferences and update UI

    } catch (e) {
      print("Google Sign-Out Error: $e");
    }
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
                  Colors.white,
                  Colors.blueAccent,
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
                      Colors.white,
                      Colors.blueAccent,
                      const Color(0xff1f8acc),
                      BorderRadius.circular(30),
                      const EdgeInsets.all(20),
                      30,
                      10,
                      "Enter the last name",
                      lastnamecontroller),
                ),
              ),Flexible(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: textfielld2(
                      Colors.white,
                      Colors.blueAccent,
                      const Color(0xff1f8acc),
                      BorderRadius.circular(30),
                      const EdgeInsets.all(20),
                      30,
                      10,
                      "Enter the your address",
                      addresscontroller),
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
                          border: Border.all(color: Colors.black,width: 1),
                          // color: Colors.grey.withOpacity(0.2),
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
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "Enter the age",
                            hintStyle: TextStyle(
                              color: Colors.blueAccent,
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
                        height: 60,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 28),
                child: GestureDetector(
                  onLongPress: (){
                    signOutFromGoogle();
                  },
                  onTap: () async {
                    try {
                      // Sign in with Google
                      await signInWithGoogle();
                      // Wait for 5 seconds
                      await Future.delayed(Duration(milliseconds: 100));

                      // Sign out from Google
                      await signOutFromGoogle();
                    } catch (e) {
                      print("Error during sign-in/sign-out: $e");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black,width: 1),
                        // color: Colors.grey.withOpacity(0.2)
                    ),
                    width: 350,
                    height: 60,
                    child: Align(alignment:Alignment.centerLeft,child: email==""?Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text("enter the email",style: TextStyle(color: Colors.blueAccent),),
                    )
                    :Align( alignment:Alignment.centerLeft,child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text("$email",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                    )),),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 28.0, bottom: 20,top: 5),
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
                            height: 50, // Set the desired width
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
                          _validateandsave(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Color(0xff1f8acc),
                                borderRadius: BorderRadius.circular(40)),
                            child: SizedBox(
                              width: 150,
                              height: 50, // Set the desired width
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

class user_photo extends StatefulWidget {
  const user_photo({super.key});

  @override
  State<user_photo> createState() => _user_photoState();
}

class _user_photoState extends State<user_photo> {
  Uint8List? webImage;
  io.File? img;
  String first_name="";
  String last_name="";
  String age="";
  String gender="";
  String email="";
  String address="";
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait mode for this page
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    view_user_details();
  }
  @override
  void dispose() {
    // Reset orientation to allow rotation when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }


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
        // await _updateuserphoto();
      } else {
        // For Mobile
        setState(() {
          img = io.File(pickedFile.path);
        });
        // _saveimg(img as String);
        // await _updateuserphoto();
      }
    } else {
      print('No image selected.');
    }
  }
  Future<void> view_user_details()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      first_name= pref.getString("first_name")??"";
      last_name=pref.getString("last_name")??"";
      age=pref.getString("age")??"";
      gender=pref.getString("gender")??"";
      email=pref.getString("email")??"";
      address=pref.getString("address")??"";
      print("email: $email");
    });
  }

  Future<void> _updateuserphoto(BuildContext context) async {
    String phone_number ="";

    // String? web_img = webImage as String?;
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try{
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

      request.fields['first_name']=first_name;
      request.fields['last_name']=last_name;
      request.fields['gender']=gender;
      request.fields['age']=age;
      request.fields['email']=email;
      request.fields['location']=address;

      var response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route)=>false);
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else if (!kIsWeb && img != null) {
      // Mobile upload
      var request = http.MultipartRequest('PUT', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'user_photo',
        img!.path,
        filename: basename(img!.path),
      ));
      request.fields['first_name']=first_name;
      request.fields['last_name']=last_name;
      request.fields['gender']=gender;
      request.fields['age']=age;
      request.fields['email']=email;
      request.fields['location']=address;

      var response = await request.send();
      print("${response.statusCode}");

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => main_home()),
                (route) => false,
          );
          SharedPreferences pref=await SharedPreferences.getInstance();
          await pref.remove('first_name');
          await pref.remove('last_name');
          await pref.remove('age');
          await pref.remove('gender');
          await pref.remove('email');
          await pref.remove('address');
          print('Image uploaded successfully.');
        }
        NotificationService().showNotification(id: 0, title: "Health hub", body: "Hi $first_name $last_name all the feature unlocked \nThanking you for Create Account in Health Hub \nAll Is Well");
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else {
      print('No image to upload.');
    }

    }catch(e){
      print("${e.toString()}");
    }
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:  EdgeInsets.only(right: 8.0),
              child: Text("hello! $first_name $last_name ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
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
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.grey,
                            //       offset: Offset(0, 2),
                            //       blurRadius: 12)
                            // ],
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: img != null
                                  ? FileImage(img!) // For Mobile (File)
                                  : webImage != null
                                  ? MemoryImage(webImage!) // For Web (Uint8List)
                                  : NetworkImage('https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png') as ImageProvider, // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                  ),
                  Positioned(
                    right: 13,
                    bottom: 20,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Color(0xff1f8acc), shape: BoxShape.circle),
                      child: IconButton(
                          onPressed: () {
                            _pickImage();
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 200,
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                  ),
                  onPressed: (){
                    if(webImage !=null  || img !=null) {
                      _updateuserphoto(context);
                    }else{
                      showDialog(context: context, builder: (context)=>AlertDialog(
                        title: Text("Error",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 25),),
                        content: Text("Must must set the photo",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                            _pickImage();
                          }, child: Text("Ok"))
                        ],
                      ));
                    }
                  },
                  child: const Center(
                    child:  Text("Create the Account",style: TextStyle(
                        color: Color(0xff1f8acc)
                    ),),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
