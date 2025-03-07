import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/doc_otp_verfication/doc_otp_verify.dart';
import 'Authentication/doc_otp_verfication/doctor_details_collect.dart';
import 'Authentication/doc_otp_verfication/doctor_details_collect_2.dart';
import 'Authentication/doc_otp_verfication/doctor_details_collect_3.dart';
import 'Authentication/otp_verfication/phone_otp.dart';
import 'choose_user_or_doc.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug, // Use 'playIntegrity' for production
  //   appleProvider: AppleProvider.appAttest, // Use 'deviceCheck' if App Attest is unavailable
  // );
  runApp(first_screen());
}

String ip = "192.168.8.17";

class first_screen extends StatefulWidget {
  const first_screen({super.key});

  @override
  State<first_screen> createState() => _first_screenState();
}

class _first_screenState extends State<first_screen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash_screen(),
    );
  }
}

class Splash_screen extends StatefulWidget {
  const Splash_screen({super.key});

  @override
  State<Splash_screen> createState() => _Splash_screenState();
}

class _Splash_screenState extends State<Splash_screen> {
  bool _doc_or_user = false;
  @override
  void initState() {
    super.initState();
    _check_doc_or_user_login();
    Timer(
      Duration(seconds: 3),
          () =>
          // Navigator.pushReplacement(
          // context, MaterialPageRoute(builder: (context) => Phone_Enter())),
          _doc_or_user
      ?Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => doc_otp()))
              :Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Phone_Enter())),

    );
  }
  Future<void> _check_doc_or_user_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool login = prefs.getBool('doc_or_user') ?? false;
    setState(() {
      _doc_or_user = login ?? false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: Center(
        child: Container(
          height: 200,
          width: 200,
          child: Image.network(
              "https://img.freepik.com/free-vector/hospital-logo-design-vector-medical-cross_53876-136743.jpg?uid=R162018176&ga=GA1.1.249085122.1736660184&semt=ais_hybrid"),

        ),
      ),
    );
  }
}

