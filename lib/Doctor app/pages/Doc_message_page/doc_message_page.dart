import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;

import 'chatting_doc_to_user_2.dart';

class doc_message extends StatefulWidget {
  const doc_message({super.key});

  @override
  State<doc_message> createState() => _doc_messageState();
}

class _doc_messageState extends State<doc_message> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Message",
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
                      hintText: 'Search a patient',
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
        body: patient_chat_show(),
      ),
    );
  }
}

class patient_chat_show extends StatefulWidget {
  const patient_chat_show({super.key});

  @override
  State<patient_chat_show> createState() => _patient_chat_showState();
}

class _patient_chat_showState extends State<patient_chat_show> {
  List<update_profile> chattting_pati =[];
  String errormessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatting_patii();
  }

  Future<void> _chatting_patii() async{
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/user_profile/user_create/"),
        headers: {"Content-Type":"application/json"}
      );
      if(response.statusCode==200){
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          chattting_pati = jsonResponse.map((data)=>update_profile.fromJson(data)).toList();
        });
      }else{
        setState(() {
          errormessage ="failed to load user_details" ;
        });
      }
    }catch(e){
      errormessage=e.toString();
    }
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Active Now",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // ✅ Allow horizontal scrolling
            child: Row(
              children: chattting_pati.map((show_patii) {
                return show_patii.id != null
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          show_patii.userPhoto != null
                              ? "http://$ip:8000${show_patii.userPhoto}"
                              : "no data ",
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "${show_patii.firstName ?? ""}${show_patii.lastName ?? ""}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
                    : SizedBox();
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Messages",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: chattting_pati.length,
            itemBuilder: (context, index) {
              var show_patiii = chattting_pati[index];
              return show_patiii.id != null
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_user(data:"${show_patiii.phoneNumber}")));
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.hardEdge,
                    shadowColor: Colors.grey,
                    child: Container(
                      height: 100,
                      // color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                // scale: 10,
                                show_patiii.userPhoto != null
                                    ? "http://$ip:8000${show_patiii.userPhoto}"
                                    : "no data ",
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left: 15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${show_patiii.firstName}${show_patiii.lastName}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                  Text("${show_patiii.location}",style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.bold),)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : Text("data");
            })
      ],
    );
  }
}



