// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:health_hub/main.dart';
// import 'package:health_hub/user%20app/pages/home.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vibration/vibration.dart';
// import '../../../Backend_information/Backend_booking_doctor.dart';
// import 'booking_history_page.dart';
//
// class get_spec_doc_user_dat_tim extends StatefulWidget {
//   final dynamic doc_phone_number;
//   final dynamic doc_name;
//   final dynamic doc_photo;
//   final dynamic booking_date;
//   final dynamic booking_time;
//   final dynamic doc_specialty;
//   final dynamic doc_service;
//   final dynamic doc_language;
//   final dynamic doc_qualification;
//   final dynamic doc_doctorLocation;
//   final dynamic doc_reg_no;
//   get_spec_doc_user_dat_tim({super.key,required this.doc_phone_number,required this.doc_photo,required this.doc_name,required this.booking_date,required this.booking_time,required this.doc_language,required this.doc_doctorLocation,required this.doc_qualification,required this.doc_service,required this.doc_specialty,required this.doc_reg_no});
//
//   @override
//   State<get_spec_doc_user_dat_tim> createState() => _get_spec_doc_user_dat_timState();
// }
//
// class _get_spec_doc_user_dat_timState extends State<get_spec_doc_user_dat_tim> {
//   booking_doctor? spec_doc_us_dat_tim;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   Future<void> _vibrate() async{
//     if (await Vibration.hasVibrator() ?? false) {
//       Vibration.vibrate(duration: 500);
//     }
//   }
//   void _delete_booking(){
//     if(widget.doc_phone_number==null){
//       if(widget.booking_date==null){
//         if(widget.booking_time==null){
//           return;
//         }
//       }
//     }else{
//       showDialog(context: context, builder: (context)=>AlertDialog(
//         title: Text("Delete Booking",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 25),),
//         content: Text("You want to Cancel the booking",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton(onPressed: (){
//                 Navigator.pop(context);
//               }, child: Text("Cancel",style: TextStyle(color: Colors.red),)),
//               TextButton(onPressed: (){
//                 _specc_doc_user_date_time();
//                 Navigator.pop(context);
//               }, child: Text("Ok",style: TextStyle(color: Colors.green),))
//             ],
//           )
//         ],
//       ));
//     }
//   }
//   Future<void> _specc_doc_user_date_time()async{
//     String phone_number ="";
//     String doc_phone_number = widget.doc_phone_number;
//     String booking_date = widget.booking_date;
//     String booking_time = widget.booking_time;
//     String inputDate = booking_date;
//
//     // Extracting the required part (2025-Mar-17)
//     List<String> parts = inputDate.split('-');
//     String formattedInput = "${parts[0]}-${parts[1]}-${parts[2]}";
//
//     // Parsing the date
//     DateTime date = DateFormat("yyyy-MMM-dd").parse(formattedInput);
//
//     // Formatting to yyyy-MM-dd
//     String outputDate = DateFormat("yyyy-MM-dd").format(date);
//     SharedPreferences perf = await SharedPreferences.getInstance();
//     setState(() {
//       phone_number = perf.getString("phone_number")??"";
//       phone_number=phone_number.replaceFirst("+", "");
//     });
//     try{
//       String encodedTime = Uri.encodeComponent(booking_time);
//       final response = await http.delete(Uri.parse("http://$ip:8000/booking_doctor/delete_specific_user_doctor/$phone_number/$doc_phone_number/$outputDate/$encodedTime/"),
//       );
//       if(response.statusCode==200){
//         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>booking_history_page()), (route)=>false);
//       }
//       else{
//         print("${response.body}");
//       }
//     }catch(e){}
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Stack(
//         children: [
//           ListView(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(15.0),
//                     child: Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(40),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Image.network(
//                             widget.doc_photo != null
//                                 ? "http://$ip:8000${widget.doc_photo}"
//                                 : "no data",
//                             scale: 5,
//                             fit: BoxFit.cover,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   widget.doc_name ?? "Unknown",
//                                   style: const TextStyle(
//                                       color: Colors.black, fontSize: 20),
//                                 ),
//                                 Text(
//                                   widget.doc_specialty ?? "No qualification",
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                                 Text("${widget.doc_service} years of exp"),
//                                 Text(widget.doc_language ?? "Tamil"),
//                                 Text(widget.doc_doctorLocation ?? "Chennai"),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 28.0, left: 15),
//                     child: Text(
//                       "Booking date and time",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 28.0, left: 15),
//                     child: Text("date :${widget.booking_date}"),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only( left: 15),
//                     child: Text("time :${widget.booking_time}"),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 28.0, left: 15),
//                     child: Text(
//                       "Treatment and producedures",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 8.0, left: 15),
//                     child: Text(widget.doc_specialty ?? "no report"),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 28.0, left: 15),
//                     child: Text(
//                       "Registration",
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 8.0, left: 15),
//                     child: Text("${widget.doc_reg_no}" ?? "no report"),
//                   ),
//                   Container(
//                     height: 200,
//                   )
//                 ],
//               )
//             ],
//           ),
//           Positioned(
//             bottom: 80,
//             child: Container(
//               margin: const EdgeInsets.all(16.0),
//               child: GestureDetector(
//                 onTap: () {
//                   _vibrate();
//                   _delete_booking();
//                 },
//                 child: Container(
//                   height: 50,
//                   width: MediaQuery.of(context).size.width * 0.92,
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       "Cancel the Booking",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../../../Backend_information/Backend_booking_doctor.dart';
import '../../../Notification_services.dart';
import '../message_page/chatting_user_to_doc_2.dart';
import 'booking_history_page.dart';
import 'feedback_user.dart';

class get_spec_doc_user_dat_tim extends StatefulWidget {
  final dynamic doc_id;
  get_spec_doc_user_dat_tim({super.key,required this.doc_id});

  @override
  State<get_spec_doc_user_dat_tim> createState() => _get_spec_doc_user_dat_timState();
}

class _get_spec_doc_user_dat_timState extends State<get_spec_doc_user_dat_tim> {
  booking_doctor? doc_book;
  bool isloading = false;
  String err = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_spec_doc_booked();
  }

  Future<void> _get_spec_doc_booked() async{
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/booking_doctor/specific_booking_user_doc/${widget.doc_id}/"));
      if(response.statusCode == 200){
        Map<String,dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          doc_book= booking_doctor.fromJson(jsonResponse);
          isloading=true;
        });
      }else{
        err = "err in the code";
        print("$err");
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  Future<void> _vibrate() async{
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> _launchPhoneDialer() async {
    String phone_number = "${doc_book!.docPhoneNumber}";
    phone_number = phone_number.replaceFirst("91", "");
    print("$phone_number");
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone_number,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> openGmail({
    required String email,
    required String subject,
    required String body,
  }) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    final url = params.toString();

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _delete_booking(){
    if(doc_book!.phoneNumber==null){
      if(doc_book!.bookingDate==null){
        if(doc_book!.bookingTime==null){
          return;
        }
      }
    }else{
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: Text("Delete Booking",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 25),),
        content: Text("You want to Cancel the booking",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Cancel",style: TextStyle(color: Colors.red),)),
              TextButton(onPressed: (){
                _specc_doc_user_date_time();
                Navigator.pop(context);
              }, child: Text("Ok",style: TextStyle(color: Colors.green),))
            ],
          )
        ],
      ));
    }
  }
  Future<void> _specc_doc_user_date_time()async{
    String phone_number ="";
    String doc_phone_number = "${doc_book!.docPhoneNumber}";
    String booking_date = "${doc_book!.bookingDate}";
    String booking_time = "${doc_book!.bookingTime}";
    String inputDate = booking_date;

    // Extracting the required part (2025-Mar-17)
    List<String> parts = inputDate.split('-');
    String formattedInput = "${parts[0]}-${parts[1]}-${parts[2]}";

    // Parsing the date
    DateTime date = DateFormat("yyyy-MMM-dd").parse(formattedInput);

    // Formatting to yyyy-MM-dd
    String outputDate = DateFormat("yyyy-MM-dd").format(date);
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number")??"";
      phone_number=phone_number.replaceFirst("+", "");
    });
    try{
      String encodedTime = Uri.encodeComponent(booking_time);
      final response = await http.delete(Uri.parse("http://$ip:8000/booking_doctor/delete_specific_user_doctor/$phone_number/$doc_phone_number/$outputDate/$encodedTime/"),
      );
      if(response.statusCode==200){
        _vibrate();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>booking_history_page()), (route)=>false);
        NotificationService().showNotification(id: 0, title: "Health Hub", body: "${doc_book!.doctorName} Appointment is Canceled");
      }
      else{
        print("${response.body}");
      }
    }catch(e){}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>feed_doctor()));
          }, icon: Icon(Icons.feedback) ),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>user_doc(data:"${doc_book!.docPhoneNumber}")));
          }, icon: Icon(Icons.chat))
        ],
      ),
      body: Padding(
        padding:  EdgeInsets.all(15.0),
        child: isloading
            ?ListView(
          children: [
            Center(
              child: doc_book!.doctorImage !=null
                  ?Image.network(
                  scale: 1,
                  "http://$ip:8000${doc_book!.doctorImage}"):SizedBox(),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("About Doctor",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name : ${doc_book!.doctorName}"),
                  Text("Specialist : ${doc_book!.specialty}"),
                  Text("Service : ${doc_book!.service} years of exp"),
                  Text("Age: ${doc_book!.docAge}"),
                  Text("gender: ${doc_book!.docGender}"),
                  Text("Know Language : ${doc_book!.language}"),
                  Text("Location : ${doc_book!.doctorLocation}"),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("Treatment and Producedures",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Specialist: ${doc_book!.specialty}"),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("Doctor Email",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${doc_book!.docEmail}"),
                  IconButton(onPressed: (){
                    openGmail(email: "${doc_book!.docEmail}", subject: "Hello!", body: "Your booking is recevied");
                  },icon: Icon(Icons.email,color: Colors.blueAccent,))
                ],
              ),
            ),Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("Doctor Phone Number",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("+${doc_book!.docPhoneNumber}"),
                  IconButton(onPressed: (){
                    _launchPhoneDialer();
                  },icon: Icon(Icons.call,color: Colors.blueAccent,))
                ],
              ),
            ),Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("Booking Date and Time",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${doc_book!.bookingDate}"),
                  Text("Time: ${doc_book!.bookingTime}")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  height: 50,
                  width: 1000,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blueAccent,width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      onPressed: (){

                        _delete_booking();
                      }, child: Text("Cancel the Booking",style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),)),
                ),
              ),
            )
          ],
        ):Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
          height: 100,))
      ),
    );
  }
}
