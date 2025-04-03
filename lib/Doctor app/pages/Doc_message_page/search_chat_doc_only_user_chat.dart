import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart%20' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Backend_information/chat_doc_only_user_chat_backend.dart';
import '../../../main.dart';
import 'chatting_doc_to_user_2.dart';

class search_doc_message extends StatefulWidget {
  const search_doc_message({super.key});

  @override
  State<search_doc_message> createState() => _search_doc_messageState();
}

class _search_doc_messageState extends State<search_doc_message> {
  List<chat_doc_only_user_chat> chat_user_only_doc_chat =[];
  String errormessage = "";
  TextEditingController searchController =TextEditingController();
  bool isloading=true;
  
  Future<void> _search_doc_mess(String query) async{
    String doc_phone_no = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no")??"";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
    });
    try{
      String docc_phone_number = Uri.encodeQueryComponent(doc_phone_no);
      String  encodedquery= Uri.encodeQueryComponent(query);
      final response = await http.get(Uri.parse("http://$ip:8000/booking_doctor/search_chat_doc_only_user_chat/?doctor_phone_number=$docc_phone_number&q=$encodedquery"));
      if(response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        if(jsonResponse is Map && jsonResponse.containsKey('result')){
          var resultList = jsonResponse['result'];
          if(resultList is List){
            setState(() {
              chat_user_only_doc_chat=resultList.map((data)=>chat_doc_only_user_chat.fromJson(data)).toList();
              isloading = false;
            });

          }else{
            setState(() {
              chat_user_only_doc_chat =[];
              isloading = false;
            });
          }
        }else{
          setState(() {
            chat_user_only_doc_chat =[];
            isloading=false;
          });
        }
      }else{
        setState(() {
          chat_user_only_doc_chat =[];
          errormessage ="no doctor found";
          isloading=false;
        });
      }
    }catch(e){
      print("object$e");
      setState(() {
        isloading=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          cursorColor: Color(0xff1f8acc),
          style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            focusColor: Colors.black,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color
            ),
            hintText: "Search Doctor...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (query) {
            if (query.length > 1) {
              _search_doc_mess(query);
            }
          },
        ),
      ),
      body: isloading ==false
      ?ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: chat_user_only_doc_chat.length,
              itemBuilder: (context, index) {
                var show_patiii = chat_user_only_doc_chat[index];
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
                                      ? "http://$ip:8000/media/${show_patiii.userPhoto}"
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
      ):Center(child: Text("no search",style: TextStyle(color: Color(0xff1f8acc)),),),
    );
  }
}
