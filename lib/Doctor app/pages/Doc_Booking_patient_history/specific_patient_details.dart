import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import '../Doc_message_page/chatting_doc_to_user_2.dart';

class specific_patient extends StatefulWidget {
  final dynamic user_id;
  specific_patient({super.key,required this.user_id});

  @override
  State<specific_patient> createState() => _specific_patientState();
}

class _specific_patientState extends State<specific_patient> {
  booking_doctor? user_book;
  bool isloading = false;
  String err ="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_spec_user_book();
  }

  Future<void> _get_spec_user_book() async{
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/booking_doctor/specific_booking_user_doc/${widget.user_id}/"));
      if(response.statusCode == 200){
        Map<String,dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          user_book= booking_doctor.fromJson(jsonResponse);
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
    String phone_number = "${user_book!.phoneNumber}";
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Booked",style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_user(data:"${user_book!.phoneNumber}")));
          }, icon: Icon(Icons.chat))
        ],
      ),
      body: Padding(
        padding:  EdgeInsets.all(15.0),
        child: isloading
        ?ListView(
          children: [
            Center(
              child: user_book!.userPhoto !=null
              ?Image.network(
                  scale: 1,
                  "http://$ip:8000${user_book!.userPhoto}"):SizedBox(),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("About Patient",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name : ${user_book!.firstName} ${user_book!.lastName}"),
                  Text("Age: ${user_book!.age}"),
                  Text("gender: ${user_book!.gender}"),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("Patient Email",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${user_book!.email}"),
                  IconButton(onPressed: (){
                    openGmail(email: "${user_book!.email}", subject: "Hello!", body: "Your booking is recevied");
                  },icon: Icon(Icons.email,color: Colors.blueAccent,))
                ],
              ),
            ),Padding(
              padding:  EdgeInsets.only(top: 18.0),
              child: Text("Patient Phone Number",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("+${user_book!.phoneNumber}"),
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
                  Text("Date: ${user_book!.bookingDate}"),
                  Text("Time: ${user_book!.bookingTime}")
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

                      }, child: Text("Cancel the Booking",style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),)),
                ),
              ),
            )
          ],
        ):Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
    height: 100,)),
      ),
    );
  }
}
