import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_hub/user%20app/pages/message_page/search_chat.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/chat_history_backend.dart';
import '../../../Backend_information/on_off_backend.dart';
import '../../../main.dart';

Timer? _chatsRefreshtime;

class user_doc extends StatefulWidget {
  final dynamic data;

  user_doc({super.key, required this.data});

  @override
  State<user_doc> createState() => _user_docState();
}

class _user_docState extends State<user_doc> with WidgetsBindingObserver {
  String doc_phone_number = "";
  String phone_number = "";
  doctor_details? get_doc_number;
  List<chat_history> get_chat_history = [];
  String errormessage = "";
  bool isloading = true;
  String sender_type = "user";
  TextEditingController messageController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doc_phone_number = widget.data ?? "";
    doc_phone_number = doc_phone_number.replaceFirst('+', '');
    _get_doc_phone_no();
    _chatsRefreshtime = Timer.periodic(Duration(seconds: 1), (timer) {
      _get_user_doctor_chat_history();
      _get_doc_phone_no();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _user_offline();
    _chatsRefreshtime?.cancel(); // Stop the timer when widget is disposed
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // Call _doc_offline when the app is minimized or closed
      _user_offline();
    }
  }

  Future<void> _create_chat_doc_only_user_chat() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.post(
          Uri.parse(
              "http://$ip:8000/booking_doctor/create_chat_doc_only_user_chat/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phone_number": phone_number,
            "doctor_phone_number": doc_phone_number
          }));
      if (response.statusCode == 201) {
        print("the user successfully add to doctor chat");
      } else {
        print("the user failed to add the doctor chat");
      }
    } catch (e) {
      errormessage = e.toString();
      print("$errormessage");
    }
  }

  Future<void> _launchPhoneDialer() async {
    phone_number = doc_phone_number;
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

  Future<void> _get_user_doctor_chat_history() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });

    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/chats/user-chat/$phone_number/$doc_phone_number/"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_chat_history =
              jsonResponse.map((data) => chat_history.fromJson(data)).toList();
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
          "receiver_phone": get_doc_number!.doctorPhoneNo,
          "message": messageController.text,
          "sender_type": sender_type
          // 'user' or 'doctor' based on role
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

  Future<void> _user_offline() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    final url =
        Uri.parse("http://$ip:8000/user_profile/user_edit/$phone_number/");
    try {
      final response = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_status": false}));
      if (response.statusCode == 200) {
        print("change successfully");
      }
    } catch (e) {
      String e1 = e.toString();
      print("offline:$e1");
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
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: get_doc_number != null
                      ? Text("${get_doc_number!.doctorName ?? "No name"}",
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : CircularProgressIndicator(), // Show a loader until data is loaded
                ),
                Center(
                  child: get_doc_number != null &&
                          get_doc_number!.docStatus == false
                      ? Text("Offline",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold))
                      : Text("Online",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                )
              ],
            ),
            // Text("Online", style: TextStyle(
            //     color: Colors.green, fontWeight: FontWeight.bold),)
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.video_camera_back_outlined)),
              IconButton(
                  onPressed: () {
                    _launchPhoneDialer();
                  },
                  icon: Icon(Icons.call)),
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.assistant_direction_rounded))
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(
              left: 10.0,
            ),
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => search_chat(
                                  data: "${widget.data}",
                                )));
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatSearchScreen(
                    // )));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1)),
                      width: 350,
                      height: 43,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 18.0),
                            child: Text(
                              "Search Chats ....",
                              style: TextStyle(color: Color(0xff1f8acc)),
                            ),
                          ))),
                )),
          ),
        ),
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
                      bool showDate = index == 0 || // First message
                          get_chat_history[index].datestamp !=
                              get_chat_history[index - 1].datestamp; // New day
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
                              showDate: showDate,
                            )
                          : Text("data");
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 50),
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
                    onPressed: () {
                      _create_chat_two();
                      _create_chat_doc_only_user_chat();
                    }),
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
  final bool showDate; // New parameter to control date visibility

  ChatBubble({
    required this.text,
    required this.senderType,
    required this.time,
    required this.date,
    required this.showDate, // Add this to constructor
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
                child: Padding(
                  padding:  EdgeInsets.only(left: 15.0,right: 15),
                  child: Text(chattime, style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          )
        : Text("No chat, Start chatting!");
  }
}
