import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_booking_doctor.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class doc_book_pati extends StatefulWidget {
  const doc_book_pati({super.key});

  @override
  State<doc_book_pati> createState() => _doc_book_patiState();
}

class _doc_book_patiState extends State<doc_book_pati> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "booked patient history",
            style: TextStyle(
                color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Padding(
              padding: EdgeInsets.only(
                left: 10.0,
              ),
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: 360,
                    child: SearchBar(
                      leading: Icon(Icons.search),
                      hintText: 'Search Booking Doctor',
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                      // shadowColor: WidgetStatePropertyAll(Colors.grey),
                      elevation: WidgetStatePropertyAll(6.0),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16.0)),
                    ),
                  )),
            ),
          ),
        ),
        body: Doc_see_user(),
      ),
    );
  }
}

class Doc_see_user extends StatefulWidget {
  const Doc_see_user({super.key});

  @override
  State<Doc_see_user> createState() => _Doc_see_userState();
}

class _Doc_see_userState extends State<Doc_see_user> {

  List<booking_doctor> booking_doc_user =[];
  bool isloading=true;
  String? errormessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _show_booked_user();
  }

  Future<void> _show_booked_user() async{
    String doc_phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_number = pref.getString('doctor_phone_no') ?? "917845711277";
      doc_phone_number=doc_phone_number.replaceFirst("+", "");
      print("$doc_phone_number");
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/booking_doctor/spec_doctor_booked/$doc_phone_number/"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if(response.statusCode == 200){
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          booking_doc_user = jsonResponse.map((data) => booking_doctor.fromJson(data)).toList();
          isloading =false;
        });

      } else{
        setState(() {
          errormessage = "failed to load user details";
          isloading = false;
        });
      }
    }catch(e){
      errormessage = e.toString();
      isloading = false;
    }



  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
    Padding(
    padding: EdgeInsets.only(top: 10.0),
    child: ListView.builder(
    itemCount: booking_doc_user.length,
    physics: BouncingScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (context, index) {
      var show_user = booking_doc_user[index];
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: ListTile(
            title: Text("${show_user.firstName} ${show_user.lastName}" ?? "no name",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Age: ${show_user.age ?? "Not Available"}"),
                Text("Gender: ${show_user.gender ?? "Not Available"}"),
                Text("Email: ${show_user.email ?? "Not Available"}"),
                Text("Address: ${show_user.location ?? "Not Available"}"),
                Text("Date: ${show_user.bookingDate ?? "Not Available"}"),
                Text("Time: ${show_user.bookingTime ?? "Not Available"}"),
              ],
            ),
          ),
        ),
      );

    }))
    ],
    );
    // return ListView(
    //   children: [
    //     Padding(
    //       padding: EdgeInsets.only(top: 10.0),
    //       child: ListView.builder(
    //         itemCount: booking_doc_user.length,
    //         physics: BouncingScrollPhysics(),
    //         shrinkWrap: true,
    //         itemBuilder: (context, index) {
    //           var show_doc = booking_doc_user[index];
    //           return booking_doc_user != null
    //             ?Padding(
    //             padding:  EdgeInsets.only(bottom: 10.0),
    //             child: Card(
    //               margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //               elevation: 5,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10),
    //               ),
    //               child: ListTile(
    //                 title: Text(
    //                   show_doc.doctorName ?? "No Name",
    //                   style: TextStyle(fontWeight: FontWeight.bold),
    //                 ),
    //                 subtitle: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text("Specialty: ${show_doc.specialty ?? "Not Available"}"),
    //                     Text("Service: ${show_doc.service ?? "Not Available"}"),
    //                     Text("Language: ${show_doc.language ?? "Not Available"}"),
    //                     Text("Qualification: ${show_doc.qualification ?? "Not Available"}"),
    //                     Text("Location: ${show_doc.doctorLocation ?? "Not Available"}"),
    //                     Text("Date: ${show_doc.bookingDate ?? "Not Available"}"),
    //                     Text("Time: ${show_doc.bookingTime ?? "Not Available"}"),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           )
    //               :Text("no data");
    //
    //         },
    //       ),
    //     ),
    //     Container(
    //       height: 100,
    //     )
    //   ],
    // );

  }
}
