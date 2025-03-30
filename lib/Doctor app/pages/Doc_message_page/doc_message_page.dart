import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_message_page/search_chat_doc_only_user_chat.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Backend_information/chat_doc_only_user_chat_backend.dart';
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

          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>search_doc_message()));
            }, icon: Icon(Icons.search,color: Color(0xff1f8acc),))
          ],
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
  List<chat_doc_only_user_chat> chat_user_only_doc_chat =[];
  String errormessage = "";
  bool isLoading = false;
  String? errorMessage;
  String doc_phone_no ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chats_user_only_doc_chat();
  }
  Future<void> _chats_user_only_doc_chat() async{
    String doc_phone_no = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no")??"";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
    });
    try{
      final response = await http.get(Uri.parse("http://$ip:8000/booking_doctor/get_chat_doc_only_user_chat/$doc_phone_no/"),
          headers: {"Content-Type":"application/json"}
      );
      if(response.statusCode==200){
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          chat_user_only_doc_chat = jsonResponse.map((data)=>chat_doc_only_user_chat.fromJson(data)).toList();
          isLoading=true;
        });
      }else{
        setState(() {
          errormessage ="failed to load user_details";
          isLoading=true;
        });
      }
    }catch(e){
      errormessage=e.toString();
    }
  }
  Future<void> _doc_online() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no")??"";
      doc_phone_no=doc_phone_no.replaceFirst("+", "");
      print("$doc_phone_no");
    });
    try{
      final response = await http.put(Uri.parse("http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
        headers: {"Content-Type":"application/json"},
          body: jsonEncode({"doc_status": true}));
      if (response.statusCode == 200) {
        print("change doc online successfully");
      }
    } catch (e) {
      String e1 = e.toString();
      print("online:$e1");
    }
  }
  @override
  Widget build(BuildContext context) {
    return  isLoading
      ?( chat_user_only_doc_chat.isNotEmpty
        ?ListView(
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
              children: chat_user_only_doc_chat.map((show_patii) {
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
            itemCount: chat_user_only_doc_chat.length,
            itemBuilder: (context, index) {
              var show_patiii = chat_user_only_doc_chat[index];
              return show_patiii.id != null
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async{
                    await _doc_online();
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
    ):Center(child: Text("No User Chat",style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),))):Center(child: CircularProgressIndicator(),);
  }
}

//
// class patient_chat_show extends StatefulWidget {
//   const patient_chat_show({super.key});
//
//   @override
//   State<patient_chat_show> createState() => _patient_chat_showState();
// }
//
// class _patient_chat_showState extends State<patient_chat_show> {
//   List<chat_doc_only_user_chat> chat_user_only_doc_chat = [];
//   String errormessage = "";
//   update_profile? userprofile; // Assuming this is a custom class; ensure it's defined
//   bool isLoading = true;
//   String? errorMessage;
//   String doc_phone_no = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _chats_user_only_doc_chat();
//   }
//
//   Future<void> _chats_user_only_doc_chat() async {
//     String doc_phone_no = "";
//     SharedPreferences perf = await SharedPreferences.getInstance();
//     doc_phone_no = perf.getString("doctor_phone_no") ?? "";
//     doc_phone_no = doc_phone_no.replaceFirst("+", "");
//
//     try {
//       final response = await http.get(
//         Uri.parse("http://$ip:8000/booking_doctor/get_chat_doc_only_user_chat/$doc_phone_no/"),
//         headers: {"Content-Type": "application/json"},
//       );
//       if (response.statusCode == 200) {
//         List<dynamic> jsonResponse = jsonDecode(response.body);
//         if (mounted) {
//           setState(() {
//             chat_user_only_doc_chat = jsonResponse
//                 .map((data) => chat_doc_only_user_chat.fromJson(data))
//                 .toList();
//             isLoading = false; // Update loading state
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             errormessage = "Failed to load user details";
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           errormessage = e.toString();
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _doc_online() async {
//     SharedPreferences perf = await SharedPreferences.getInstance();
//     if (mounted) {
//       setState(() {
//         doc_phone_no = perf.getString("doctor_phone_no") ?? "";
//         doc_phone_no = doc_phone_no.replaceFirst("+", "");
//       });
//     }
//     try {
//       final response = await http.put(
//         Uri.parse("http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"doc_status": true}),
//       );
//       if (response.statusCode == 200) {
//         print("Doctor status updated successfully");
//       } else {
//         print("Failed to update doctor status: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error updating doctor status: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Active Now",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: chat_user_only_doc_chat.map((show_patii) {
//                 return show_patii.id != null
//                     ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundImage: NetworkImage(
//                           show_patii.userPhoto != null
//                               ? "http://$ip:8000${show_patii.userPhoto}"
//                               : "https://via.placeholder.com/150", // Fallback image
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         "${show_patii.firstName ?? ""} ${show_patii.lastName ?? ""}",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 )
//                     : SizedBox();
//               }).toList(),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Messages",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ),
//         isLoading
//             ? Center(child: CircularProgressIndicator()) // Show loading indicator
//             : ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
//           itemCount: chat_user_only_doc_chat.length,
//           itemBuilder: (context, index) {
//             var show_patiii = chat_user_only_doc_chat[index];
//             return show_patiii.id != null
//                 ? Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GestureDetector(
//                 onTap: () async {
//                   await _doc_online();
//                   if (mounted) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => doc_user(
//                             data: "${show_patiii.phoneNumber}"),
//                       ),
//                     );
//                   }
//                 },
//                 child: Card(
//                   margin: EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 5),
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   clipBehavior: Clip.hardEdge,
//                   shadowColor: Colors.grey,
//                   child: Container(
//                     height: 100,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           CircleAvatar(
//                             radius: 40,
//                             backgroundImage: NetworkImage(
//                               show_patiii.userPhoto != null
//                                   ? "http://$ip:8000${show_patiii.userPhoto}"
//                                   : "https://via.placeholder.com/150",
//                             ),
//                           ),
//                           Padding(
//                             padding:
//                             EdgeInsets.only(left: 15.0),
//                             child: Column(
//                               mainAxisAlignment:
//                               MainAxisAlignment.center,
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "${show_patiii.firstName ?? ""} ${show_patiii.lastName ?? ""}",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 20),
//                                 ),
//                                 Text(
//                                   "${show_patiii.location ?? "Unknown"}",
//                                   style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//                 : SizedBox(); // Return empty widget instead of Text("data")
//           },
//         ),
//         if (errormessage.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               errormessage,
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//       ],
//     );
//   }
// }