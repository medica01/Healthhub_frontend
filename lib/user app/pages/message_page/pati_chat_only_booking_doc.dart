import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:health_hub/Backend_information/show_booking_doc_chat_user.dart';
import 'package:health_hub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'chatting_user_to_doc_2.dart';

class booking_doc_message extends StatefulWidget {
  const booking_doc_message({super.key});

  @override
  State<booking_doc_message> createState() => _booking_doc_messageState();
}

class _booking_doc_messageState extends State<booking_doc_message> {
  List<show_booking_doc_chat_user> show_book_doc_chat = [];
  bool isloading = false;
  String err = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _show_booking_doc_chat();
  }

  Future<void> _show_booking_doc_chat() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/booking_doctor/get_show_booked_doc_chat/$phone_number/"));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          show_book_doc_chat = jsonResponse
              .map((data) => show_booking_doc_chat_user.fromJson(data))
              .toList();
          isloading = true;
        });
      } else {
        err = "err in the code";
        print("$err");
        isloading = true;
      }
    } catch (e) {
      err = e.toString();
      print("$err");
    }
  }

  Future<void> _delete_doc_user_chat(int doc_phone_no) async{
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try{
      final response = await http.delete(Uri.parse("http://$ip:8000/booking_doctor/delete_booked_doc_chat/$phone_number/$doc_phone_no/"));
      if(response.statusCode==204){
        _show_booking_doc_chat();
      }
    }catch(e){}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: isloading
        ?(show_book_doc_chat.isNotEmpty
            ?ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active Now",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search_rounded,
                      color: Colors.blueAccent,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // ✅ Allow horizontal scrolling
                child: Row(

                  children: show_book_doc_chat.map((show_docc) {
                    return show_docc.id != null
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    show_docc.doctorImage != null
                                        ? "http://$ip:8000${show_docc.doctorImage}"
                                        : "no data ",
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  show_docc.doctorName ?? "Unknown",
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
              child: Text(
                "Messages",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: show_book_doc_chat.length,
                itemBuilder: (context, index) {
                  var show_docc = show_book_doc_chat[index];
                  return show_docc.id != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                          AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              horizontalOffset: 500.0,
                              verticalOffset: 500,
                              // curve: Curves.elasticIn,
                              child: FadeInAnimation(
                                child: GestureDetector(
                                  onLongPress: (){
                                    showDialog(context: context, builder: (context)=>AlertDialog(
                                      title: Text("Notice!",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 25),),
                                      content: Text("Did you want to delete this Dr.${show_docc.doctorName} from booking chat!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                      actions: [
                                        Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(onPressed: (){
                                        Navigator.pop(context);
                                      }, child: Text("Cancel",style: TextStyle(color: Colors.green),)),

                                            TextButton(onPressed: (){
                                              _delete_doc_user_chat(show_docc.doctorPhoneNo as int);
                                              Navigator.pop(context);
                                            }, child: Text("Ok",style: TextStyle(color: Colors.red),)),
                                          ],
                                        )
                                      ],
                                    ));

                                  },
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => user_doc(
                                                data: "${show_docc.doctorPhoneNo}")));
                                  },
                                  child: Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    shadowColor: Colors.grey,
                                    child: Container(
                                      height: 100,
                                      color: Colors.white54,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 40,
                                              backgroundImage: NetworkImage(
                                                // scale: 10,
                                                show_docc.doctorImage != null
                                                    ? "http://$ip:8000${show_docc.doctorImage}"
                                                    : "no data ",
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 15.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${show_docc.doctorName}",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                  Text(
                                                    "${show_docc.specialty}",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold),
                                                  )
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
                            ),
                          )
                        )
                      : Text("data");
                }),
            Container(
              height: 100,
            )
          ],
        ):Center(child: Text("No Booking Doctor Chat",style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),))
        ):Center(child: Text("No Booking Doctor Chat",style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),)),
    );
  }
}

