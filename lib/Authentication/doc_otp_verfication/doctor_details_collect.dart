import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../allfun.dart';
import '../../main.dart';
import 'doctor_details_collect_2.dart';
import 'doctor_details_collect_3.dart';

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
  String doc_phone_no = "";
  String? errormessage;

  String doc_email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      await pref.setString("doc_email", user.email!);
      // Update the local state to trigger UI rebuild
      setState(() {
        doc_email = user.email!;
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
    if (doc_email.isEmpty) {
      missingfield.add("enter the email");
    }
    if (age.text.isEmpty || int.tryParse(age.text) == null ||
        int.parse(age.text) < 23 || int.parse(age.text) > 100) {
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
          builder: (context) =>
              AlertDialog(
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

  Future<void> _update_doc() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    await perf.setString("doc_first_name", first_name.text);
    await perf.setString("doc_last_name", last_name.text);
    await perf.setString("doc_age", age.text);
    // await perf.setString("doc_email", email.text);
    await perf.setString("doc_language", language.text);
    await perf.setString("doc_location", location.text);
    await perf.setString("doc_gender", gender[selectgender]);
    Navigator.push(context, MaterialPageRoute(builder: (context) => doc_bio()));
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery
        .of(context)
        .size;
    return SingleChildScrollView(
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
                    doc_form_field("First name", first_name,
                    TextInputType.text),
                doc_form_field("Last name", last_name, TextInputType.text),
                // doc_form_field("Email", email, TextInputType.emailAddress),
                Padding(padding: EdgeInsets.only(top: 8.0, bottom: 14,
                    left: 13, right: 13),
                  child: GestureDetector(
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
                      height: 48,
                      width: 300,
                      child: Align( alignment : Alignment.centerLeft,child: doc_email =="" ?Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text("enter the email",style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold,fontSize: 16),),
                      )
                      :Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text("$doc_email",style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold,fontSize: 16),),
                        ),
                      )
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black,width: 1)
                      ),
                    ),
                  ),
                ),
              doc_form_field("Age", age, TextInputType.number),
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 10),
            child: Text(
              "Gender:",
              style: TextStyle(
                  color: Color(0xff1f8acc),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                gender.length,
                    (index) =>
                    GestureDetector(
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
          doc_form_field("Known Language", language, TextInputType.text),
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
                      selectgender = -1;
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
                  onPressed: () =>
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
    );
  }
}