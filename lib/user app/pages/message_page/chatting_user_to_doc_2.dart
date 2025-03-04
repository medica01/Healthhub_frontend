import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/chat_history_backend.dart';
import '../../../main.dart';

Timer? _chatsRefreshtime;
class user_doc extends StatefulWidget {
  final dynamic data;

  user_doc({super.key, required this.data});

  @override
  State<user_doc> createState() => _user_docState();
}

class _user_docState extends State<user_doc> {
  String doc_phone_number = "";
  String phone_number ="";
  doctor_details? get_doc_number;
  List<chat_history> get_chat_history = [];
  String errormessage = "";
  bool isloading = true;
  String sender_type = "user";
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doc_phone_number = widget.data ?? "917845711277";
    doc_phone_number = doc_phone_number.replaceFirst('+', '');
    _get_doc_phone_no();
    _chatsRefreshtime = Timer.periodic(Duration(seconds: 1), (timer){
      _get_user_doctor_chat_history();
    });

  }
  @override
  void dispose() {
    _chatsRefreshtime?.cancel(); // Stop the timer when widget is disposed
    super.dispose();
  }

  Future<void> _get_user_doctor_chat_history() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });

    try {
      final response = await http.get(
        Uri.parse("http://$ip:8000/chats/user-chat/$phone_number/$doc_phone_number/"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_chat_history = jsonResponse.map((data) => chat_history.fromJson(data)).toList();
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

  Future<void> _create_chat_two() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });

    if (get_doc_number == null) {
      print("Doctor details are not loaded yet.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://$ip:8000/chats/send-message/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_phone": phone_number,
          "receiver_phone": get_doc_number!.doctorPhoneNo, // Ensure doctor number is correct
          "message": messageController.text,
          "sender_type": sender_type // 'user' or 'doctor' based on role
        }),
      );



      if (response.statusCode == 201) {
        await _get_user_doctor_chat_history();
        messageController.clear();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Send Failed"),
            content: Text("Message is empty"),
          ),
        );
      }
    } catch (e) {
      errormessage = e.toString();
      print("$errormessage");
    }
  }

  Future<void> _get_doc_phone_no() async {
    try {
      final response = await http.get(
          Uri.parse(
              "http://$ip:8000/doctor_details/get_doc_phone/$doc_phone_number/"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_doc_number = doctor_details.fromJson(jsonResponse);
        });
      } else {
        errormessage = response.body;
      }
    } catch (e) {
      errormessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  get_doc_number != null && get_doc_number!.doctorImage != null
                      ? NetworkImage(
                          "http://$ip:8000${get_doc_number!.doctorImage}")
                      : AssetImage('assets/default_avatar.png')
                          as ImageProvider, // Use a default image
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: get_doc_number != null
                  ? Text("${get_doc_number!.doctorName ?? "No name"}",
                      style: TextStyle(fontWeight: FontWeight.bold))
                  : CircularProgressIndicator(), // Show a loader until data is loaded
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.video_camera_back_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.call)),
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.assistant_direction_rounded))
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isloading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: get_chat_history.length,
              itemBuilder: (context, index) {
                var chat = get_chat_history[index];
                return chat !=null || chat.message != null || chat.docPhoneNo != null || chat.userPhoneNo != null || chat.senderType != null || chat.datestamp != null
                  ?ChatBubble(
                  text: chat.message,
                  senderType: chat.senderType,
                  time:chat.timestamp,
                  date:chat.datestamp
                )
                    :Text("data");
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 8.0,right: 8,top: 8,bottom: 100),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: ()=>_create_chat_two(),
                ),
              ],
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

  ChatBubble({required this.text, required this.senderType,required this.time,required this.date});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    bool isUser = widget.senderType == 'user';
    return  widget.text !=null
      ?Column(
      children: [
        Center(
          child: Card(
            child: Container(
              height: 25,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey
              ),
              child: Center(child: Text(widget.date,style: TextStyle(fontSize: 10),)),
            ),
          ),
        ),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
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
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
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
            child: Text(widget.time, style: TextStyle(fontSize: 10)),
          ),
        ),
      ],
    )
        : Text("No chat, Start chatting!");
  }
}
