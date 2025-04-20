// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart%20' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../Backend_information/chat_history_backend.dart';
// import '../../../main.dart';
// import '../Doc_profile_page/doc_photo_view.dart';
//
// class only_photo extends StatefulWidget {
//   final dynamic doc_phone;
//   final dynamic pati_phone;
//
//   const only_photo(
//       {super.key, required this.doc_phone, required this.pati_phone});
//
//   @override
//   State<only_photo> createState() => _only_photoState();
// }
//
// class _only_photoState extends State<only_photo> {
//   List<chat_history> get_chats_history = [];
//   String doc_phone_number = "";
//   bool isloading = true;
//   String errormessage = '';
//   String sender_type = "doctor";
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _get_user_doctor_chat_history();
//   }
//
//   Future<void> _get_user_doctor_chat_history() async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://$ip:8000/chats/user-chat/${widget.pati_phone}/${widget
//             .doc_phone}/"),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         List<dynamic> jsonResponse = jsonDecode(response.body);
//         setState(() {
//           get_chats_history =
//               jsonResponse.map((data) => chat_history.fromJson(data)).toList();
//           isloading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errormessage = e.toString();
//         isloading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isUser = true;
//     return Scaffold(
//       appBar: AppBar(
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: isloading
//                 ? Center(child: Text("no search",style: TextStyle(color: Color(0xff1f8acc)),))
//                 : ListView.builder(
//               itemCount: get_chats_history.length,
//               itemBuilder: (context, index) {
//                 var chat = get_chats_history[index];
//                 bool showDate = index==0||
//                     get_chats_history[index].datestamp!=
//                         get_chats_history[index-1].datestamp;
//                 return chat.id !=null || chat.message != null || chat.docPhoneNo != null || chat.userPhoneNo != null || chat.senderType != null || chat.datestamp != null
//                     ?ChatBubble(
//                     image: chat.image,
//                     senderType: chat.senderType,
//                     time:chat.timestamp,
//                     date:chat.datestamp,showDate : showDate
//                 )
//                     :Text("data");
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//     }
// }
// class ChatBubble extends StatefulWidget {
//   final dynamic image;
//   final dynamic senderType;
//   final dynamic time;
//   final dynamic date;
//   final dynamic showDate;
//
//   ChatBubble({required this.image, required this.senderType,required this.time,required this.date,required this.showDate});
//
//   @override
//   State<ChatBubble> createState() => _ChatBubbleState();
// }
//
// class _ChatBubbleState extends State<ChatBubble> {
//   DateTime now = DateTime.now();
//   String forr = "";
//   String chattime = "";
//   DateTime chatt=DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//
//     setState(() {
//       forr = DateFormat("yyyy-MM-dd").format(DateTime.now());
//       chattime = widget.time;
//
//       try {
//         // Take only HH:mm part
//         String timeOnly = chattime.substring(0, 5); // e.g., "19:39"
//         DateTime chatt = DateFormat("HH:mm").parse(timeOnly);
//
//         // Convert to 12-hour format with AM/PM
//         chattime = DateFormat("hh:mm a").format(chatt);
//         print(chattime); // Should print "07:39 PM"
//       } catch (e) {
//         print("Error parsing time: $e");
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     bool isUser = widget.senderType == 'doctor';
//     return  widget.image !=null
//         ?Column(
//       children: [
//         if (widget.showDate) // Only show date if showDate is true
//           widget.date != forr
//               ? (Center(
//             child: Card(
//               child: Container(
//                 height: 25,
//                 width: 70,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.grey,
//                 ),
//                 child: Center(
//                   child: Text(
//                     widget.date,
//                     style: TextStyle(
//                         fontSize: 10, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ))
//               : Center(
//             child: Card(
//               child: Container(
//                 height: 25,
//                 width: 70,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.grey,
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Today",
//                     style: TextStyle(
//                         fontSize: 10, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         Align(
//           alignment:
//           isUser ? Alignment.centerRight : Alignment.centerLeft,
//           child: widget.image==null
//               ?SizedBox()
//               :Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GestureDetector(
//               onTap: (){
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_view(doc_photo: "${widget.image}",)));
//               },
//               child: Container(
//                   clipBehavior: Clip.hardEdge,
//                   // height: 200,
//                   width: 200,
//                   decoration: BoxDecoration(
//                     // border: Border.all(color: isUser ? Colors.blue : Colors.grey,width: 2),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(15),
//                       topRight: Radius.circular(15),
//                       bottomLeft: isUser ? Radius.circular(15) : Radius.zero,
//                       bottomRight: isUser ? Radius.zero : Radius.circular(15),
//                     ),
//                   ),
//                   child: Image.network(
//
//                     // scale: 1,
//                       fit: BoxFit.cover,
//                       "http://$ip:8000${widget.image}")
//               ),
//             ),
//           ),
//         ),
//         Align(
//           alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//           child: Padding(
//             padding: EdgeInsets.only(left: 15.0, right: 15),
//             child: Container(
//
//               child: Text(chattime, style: TextStyle(fontSize: 10)),
//             ),
//           ),
//         ),
//       ],
//     )
//         : SizedBox();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Replace with your actual imports
import '../../../Backend_information/chat_history_backend.dart';
import '../../../main.dart';
import '../Doc_profile_page/doc_photo_view.dart';

class only_photo extends StatefulWidget {
  final dynamic doc_phone;
  final dynamic pati_phone;
  final dynamic user_type;

  const only_photo({
    super.key,
    required this.doc_phone,
    required this.pati_phone,
    required this.user_type
  });

  @override
  State<only_photo> createState() => _only_photoState();
}

class _only_photoState extends State<only_photo> {
  List<chat_history> get_chats_history = [];
  String doc_phone_number = "";
  bool isloading = true;
  String errormessage = '';
  String sender_type = "";

  @override
  void initState() {
    super.initState();
    _get_user_doctor_chat_history();
    sender_type = widget.user_type;
  }

  Future<void> _get_user_doctor_chat_history() async {
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/chats/user-chat/${widget.pati_phone}/${widget.doc_phone}/"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_chats_history =
              jsonResponse.map((data) => chat_history.fromJson(data)).toList();
          isloading = false;
        });
      } else {
        setState(() {
          errormessage = 'Failed to load chats: ${response.statusCode}';
          isloading = false;
        });
      }
    } catch (e) {
      setState(() {
        errormessage = e.toString();
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos"),
      ),
      body: Column(
        children: [
          Expanded(
            child: isloading
                ? Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
              height: 100,))
                : ListView.builder(
              itemCount: get_chats_history.length,
              itemBuilder: (context, index) {
                var chat = get_chats_history[index];
                bool showDate = index == 0 || // First message
                    get_chats_history[index].datestamp !=
                        get_chats_history[index - 1].datestamp; // New day
                return chat.id != null ||
                    chat.message != null ||
                    chat.docPhoneNo != null ||
                    chat.userPhoneNo != null ||
                    chat.senderType != null ||
                    chat.datestamp != null
                    ? ChatBubble(
                  message: chat.message,
                  senderType: chat.senderType,
                  time: chat.timestamp,
                  image: chat.image,
                  date: chat.datestamp,
                  showDate: showDate,
                    sender_types: sender_type
                )
                    : Text("data");
              },
            ),
          ),

        ],
      ),
    );
  }
}

class ChatBubble extends StatefulWidget {
  final String? image;
  final String? senderType;
  final String? time;
  final String? message;
  final String? date;
  final bool showDate;
  final String sender_types;

   ChatBubble({
    this.image,
    this.senderType,
    this.time,
    this.date,
    required this.showDate,
    this.message,
     required this.sender_types

  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String forr = "";
  String chattime = "";

  @override
  void initState() {
    super.initState();
    // Compute forr and chattime without setState
    forr = DateFormat("yyyy-MM-dd").format(DateTime.now());
    chattime = widget.time ?? "";

    if (chattime.isNotEmpty) {
      try {
        String timeOnly = chattime.substring(0, 5); // e.g., "19:39"
        DateTime chatt = DateFormat("HH:mm").parse(timeOnly);
        chattime = DateFormat("hh:mm a").format(chatt);
        print('Parsed time: $chattime'); // Debug
      } catch (e) {
        print("Error parsing time: $e");
        chattime = widget.time ?? "";
      }
    }
    print(" show date: ${widget.showDate}");
    print("${widget.date}");
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = widget.senderType == widget.sender_types;
    return widget.image != null && widget.image!.isNotEmpty
        ? Column(
      children: [
        if (widget.showDate)
          widget.date != forr
              ? Center(
            child: Card(
              child: Container(
                height: 25,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                child: Center(
                  child: Text(
                    widget.date!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
              : Center(
            child: Card(
              child: Container(
                height: 25,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
                child: Center(
                  child: Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        doc_view(doc_photo: widget.image!),
                  ),
                );
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: isUser ? Radius.circular(15) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : Radius.circular(15),
                  ),
                ),
                child: Image.network(
                  "http://$ip:8000${widget.image}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15),
            child: Text(
              chattime,
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    )
        : SizedBox();
  }
}