import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/chat_history_backend.dart';
import '../../../main.dart';

class search_chat extends StatefulWidget {
  final dynamic data;

  search_chat({super.key, required this.data});

  @override
  State<search_chat> createState() => _search_chatState();
}

class _search_chatState extends State<search_chat> {
  final TextEditingController searchController = TextEditingController();
  String doc_phone_number = "";
  String phone_number = "";
  List<chat_history> get_chat_history = [];
  String errormessage = "";
  bool isloading = true;
  String sender_type = "user";
  TextEditingController messageController = TextEditingController();
  TextEditingController search_chat = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doc_phone_number = widget.data ?? "917845711277";
    doc_phone_number = doc_phone_number.replaceFirst('+', '');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _search_chat(String query) async{
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    if(query.isEmpty)return;
    setState(() {
      isloading =true;
    });
    try{
      String encoded_phone_number = Uri.encodeQueryComponent(phone_number);
      String encoded_doc_phone_number = Uri.encodeQueryComponent(doc_phone_number);
      String encodedQuery = Uri.encodeQueryComponent(query);
      final response = await http.get(Uri.parse("http://$ip:8000/chats/search_chat/?user_phone_no=$encoded_phone_number&doc_phone_no=$encoded_doc_phone_number&q=$encodedQuery"));
      if(response.statusCode ==200){
        var jsonResponse= jsonDecode(response.body);
        print("jsonresponse: $jsonResponse");
        if(jsonResponse is Map && jsonResponse.containsKey('result')){
          var resultList = jsonResponse['result'];
          if(resultList is List){
            setState(() {
              get_chat_history = resultList.map((data)=>chat_history.fromJson(data)).toList();
              isloading=false;
            });
          }else{
            setState(() {
              get_chat_history =[];
              isloading = false;
            });
          }
        }else{
          setState(() {
            get_chat_history =[];
            isloading=false;
          });
        }
      }else{
        setState(() {
          get_chat_history =[];
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        },child: Container(child: Icon(Icons.arrow_downward)),),
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: searchController,
          cursorColor: Color(0xff1f8acc),
          style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            focusColor: Colors.black,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color
            ),
            hintText: "Search chats...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (query) {
            if (query.length > 1) {
              _search_chat(query);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isloading
                ? Center(child: Text("no search",style: TextStyle(color: Color(0xff1f8acc)),),)
                : ListView.builder(
                    itemCount: get_chat_history.length,
                    itemBuilder: (context, index) {
                      var chat = get_chat_history[index];
                      bool showDate = index==0||
                      get_chat_history[index].datestamp!=
                      get_chat_history[index-1].datestamp;
                      return chat != null ||
                              chat.message != null ||
                              chat.docPhoneNo != null ||
                              chat.userPhoneNo != null ||
                              chat.senderType != null ||
                              chat.datestamp != null
                          ? ChatBubble(
                              text: chat.message,
                              senderType: chat.senderType,
                              time: chat.timestamp,
                              date: chat.datestamp,
                        showDate: showDate
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
  final dynamic text;
  final dynamic senderType;
  final dynamic time;
  final dynamic date;
  final dynamic showDate;

  ChatBubble({required this.text,
    required this.senderType,
    required this.time,
    required this.date,
    required this.showDate
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  DateTime now = DateTime.now();
  String forr = "";
  String chattime = "";
  DateTime chatt=DateTime.now();

  @override
  void initState() {
    super.initState();

    setState(() {
      forr = DateFormat("yyyy-MM-dd").format(DateTime.now());
      chattime = widget.time;

      try {
        // Take only HH:mm part
        String timeOnly = chattime.substring(0, 5); // e.g., "19:39"
        DateTime chatt = DateFormat("HH:mm").parse(timeOnly);

        // Convert to 12-hour format with AM/PM
        chattime = DateFormat("hh:mm a").format(chatt);
        print(chattime); // Should print "07:39 PM"
      } catch (e) {
        print("Error parsing time: $e");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isUser = widget.senderType == 'user';
    return widget.text != null
        ? Column(
      children: [
        if (widget.showDate) // Only show date if showDate is true
          widget.date != forr
              ? (Center(
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
                    widget.date,
                    style: TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
          ))
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
                        fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: isUser ? Radius.circular(15) : Radius.zero,
                bottomRight: isUser ? Radius.zero : Radius.circular(15),
              ),
            ),
            child: Text(widget.text, style: TextStyle(fontSize: 16)),
          ),
        ),
        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            // margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            // decoration: BoxDecoration(
            //   color: isUser ? Colors.blue[100] : Colors.grey[300],
            //   borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(15),
            //     topRight: Radius.circular(15),
            //     bottomLeft: isUser ? Radius.circular(15) : Radius.zero,
            //     bottomRight: isUser ? Radius.zero : Radius.circular(15),
            //   ),
            // ),
            child: Text(chattime, style: TextStyle(fontSize: 10)),
          ),
        ),
      ],
    )
        : Text("No chat, Start chatting!");
  }
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../main.dart';
//
// class ChatSearchScreen extends StatefulWidget {
//   @override
//   _ChatSearchScreenState createState() => _ChatSearchScreenState();
// }
//
// class _ChatSearchScreenState extends State<ChatSearchScreen> {
//   final String baseUrl = "http://$ip:8000/chats/search_chat?user_phone_no=917845711277&doc_phone_no=916380642005?q=hi";
//   String userPhoneNo = "917845711277";  // Change this dynamically
//   String docPhoneNo = "916380642005";   // Change this dynamically
//   String query = "hi";  // Change as per user input
//   List<dynamic> messages = [];
//
//   Future<void> fetchChatMessages() async {
//     final url = Uri.parse("$baseUrl");
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           messages = data['result'];
//         });
//       } else {
//         print("Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchChatMessages();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat Search")),
//       body: messages.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: messages.length,
//         itemBuilder: (context, index) {
//           var message = messages[index];
//           return ListTile(
//             title: Text(message['message']),
//             subtitle: Text("${message['sender_type']} - ${message['timestamp']}"),
//           );
//         },
//       ),
//     );
//   }
// }
