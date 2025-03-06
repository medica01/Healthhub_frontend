import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
import 'package:health_hub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../Authentication/doc_otp_verfication/doc_otp_verify.dart';
import '../../../allfun.dart';

class doc_profiles extends StatefulWidget {
  const doc_profiles({super.key});

  @override
  State<doc_profiles> createState() => _doc_profilesState();
}

class _doc_profilesState extends State<doc_profiles> {
  Future<bool> signOutFromDocphone() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the 'login' key to clear the logged-in state
      await prefs.remove('doc_login');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => doc_otp()),
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
      home: Scaffold(
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
                  onPressed: ()=>signOutFromDocphone(),
                  icon: Icon(
                    Icons.logout,
                    color: Color(0xff1f8acc),
                    size: 30,
                  ),
                )),
          ],
        ),
        body: doc_profile_page(),
      ),
    );
  }
}

class doc_profile_page extends StatefulWidget {
  const doc_profile_page({super.key});

  @override
  State<doc_profile_page> createState() => _doc_profile_pageState();
}

class _doc_profile_pageState extends State<doc_profile_page> {
  String errormessage ="";
  doctor_details? _get_doc_details;
  String doc_phone_no="";
  bool isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_doctor_details();
  }

  Future<void> _get_doctor_details() async{
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no")??"";
      doc_phone_no=doc_phone_no.replaceFirst("+", "");
      print("$doc_phone_no");
    });
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
        headers: {"Content-Type":"application/json"},
      );
      if(response.statusCode==200){
        Map<String,dynamic>jsonResponse = jsonDecode(response.body);
        setState(() {
          _get_doc_details = doctor_details.fromJson(jsonResponse);

        });
      }
    }catch(e){}
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
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage:
            _get_doc_details != null && _get_doc_details!.doctorImage != null
                ? NetworkImage(
                "http://$ip:8000${_get_doc_details!.doctorImage}")
                : AssetImage('assets/default_avatar.png')
            as ImageProvider, // Use a default image
          )
        ),
        isloading
            ? Center(child: Text("guest"))
            : _get_doc_details != null
            ? Center(
          child: Text(
            "${_get_doc_details!.doctorName ?? ''}",
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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => personal_details()),
          // );
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
