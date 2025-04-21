import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
import 'package:health_hub/main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../Authentication/doc_otp_verfication/doc_otp_verify.dart';
import '../../../Authentication/doc_otp_verfication/doctor_details_collect_2.dart';
import '../../../allfun.dart';
import '../../../user app/medicine_page/pages/add_address/add_another_address.dart';
import '../../../user app/medicine_page/pages/add_address/change_user_address.dart';
import 'doc_personal_detials2.dart';
import 'doc_photo_view.dart';

class doc_profiles extends StatefulWidget {
  const doc_profiles({super.key});

  @override
  State<doc_profiles> createState() => _doc_profilesState();
}

class _doc_profilesState extends State<doc_profiles> {

  Future<void> doc_logout()async{
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
              signOutFromDocphone();
              Navigator.pop(context);
            }, child: Text("Ok",style: TextStyle(color: Colors.red),))
          ],
        )
      ],
    ));
  }
  Future<bool> signOutFromDocphone() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Remove the 'login' key to clear the logged-in state
      await prefs.remove('doc_login');
      await prefs.remove('doctor_phone_no');
      await prefs.remove('phone_number');
      await prefs.remove('address_id');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => doc_otp_verfiy()),
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
      home:  Scaffold(
        backgroundColor: Color(0xfffdfdfd),
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
                    onPressed: ()=>doc_logout(),
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
          isloading=true;
        });
      }
    }catch(e){
      print("${e.toString()}");
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
    return isloading
      ?ListView(
      children: [
        Center(
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_view(
                doc_photo: _get_doc_details!.doctorImage
              )));
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
              _get_doc_details != null && _get_doc_details!.doctorImage != null
                  ? NetworkImage(
                  "http://$ip:8000${_get_doc_details!.doctorImage}")
                  : NetworkImage('https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png')
              as ImageProvider, // Use a default image
            ),
          )
        ),
        !isloading
            ? Center(child: Text("guest",style:
        TextStyle(fontSize: 23, fontWeight: FontWeight.bold),))
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => doc_personal()),
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

      ],
    ):Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
      height: 100,));
  }
}
