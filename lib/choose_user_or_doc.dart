import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Authentication/doc_otp_verfication/doc_otp_verify.dart';
import 'Authentication/otp_verfication/phone_otp.dart';
import 'Doctor app/doctor_homepage.dart';

class choose_use_doc extends StatefulWidget {
  const choose_use_doc({super.key});

  @override
  State<choose_use_doc> createState() => _choose_use_docState();
}

class _choose_use_docState extends State<choose_use_doc> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text("Choose User Role",style: TextStyle(color: Color(0xff1f8acc)),),
        ),
        body: user_doc(),
      ),
    );
  }
}

class user_doc extends StatefulWidget {
  const user_doc({super.key});

  @override
  State<user_doc> createState() => _user_docState();
}

class _user_docState extends State<user_doc> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async{
                SharedPreferences pref = await SharedPreferences.getInstance();
                await pref.setBool("doc_or_user", true);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_otp_verfiy()));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Square border
                  borderRadius: BorderRadius.circular(20)
                ),
                height: 120,
                width: 110,
                child: Image.asset("assets/img_2.png"),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(bottom: 15.0),
              child: const Text("Doctor",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 15.0),
              child: GestureDetector(
                onTap: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  await pref.setBool("doc_or_user", false);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneEntryPage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(20)// Square border
                  ),
                  height: 120,
                  width: 110,
                  child: Image.asset("assets/img_4.png",),
                ),
              ),
            ),
            const Text("Patient",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          ],
        ),
      ),
    );
  }
}

