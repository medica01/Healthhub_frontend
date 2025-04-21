import 'dart:async';
import 'dart:convert';

import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_doctor_details.dart';
import 'package:health_hub/Backend_information/chat_history_backend.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_message_page/search_chat_doc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Backend_information/on_off_backend.dart';
import '../../../Notification_services.dart';
import '../../../main.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../../user app/Other_feature/photo_view.dart';
import '../Doc_profile_page/doc_photo_view.dart';
import 'chat_photo_only.dart';

Timer? _chatRefreshTime;

class doc_user extends StatefulWidget {
  final dynamic data;
  doc_user({super.key, required this.data});

  @override
  State<doc_user> createState() => _doc_userState();
}

class _doc_userState extends State<doc_user> with WidgetsBindingObserver {
  String doc_phone_number = "";
  String user_phone_number = "";
  update_profile? get_user_number;
  List<chat_history> get_chats_history = [];
  String errormessage = "";
  bool isloading = true;
  String sender_type = "doctor";
  // doctor_details? user_on_off;
  TextEditingController messageController = TextEditingController();
  String doc_phone_no ="";
  final ScrollController _scrollController = ScrollController();
  final _picker = ImagePicker();
  Uint8List? webImage;
  io.File? img;

  @override
  void initState() {
    super.initState();
    user_phone_number = widget.data ?? "";
    user_phone_number = user_phone_number.replaceFirst("+", "");
    _get_user_phone_no();
    _chatRefreshTime = Timer.periodic(Duration(seconds: 1), (timer) {
      _get_user_doctor_chat_history();
      _get_user_phone_no();
    });
    // Add this widget as an observer to listen to lifecycle events
    WidgetsBinding.instance.addObserver(this);
    _get_user_doctor_chat_history().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _chatRefreshTime?.cancel(); // Cancel the timer
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _doc_offline();
    super.dispose();

  }

  // Listen to app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      // Call _doc_offline when the app is minimized or closed
      _doc_offline();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }else {
      print("ScrollController has no clients yet.");
    }
  }

  Future<void> _launchPhoneDialer() async {
    String phone_number = user_phone_number;
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
      doc_phone_number = perf.getString("doctor_phone_no") ?? "917845711277";
      doc_phone_number = doc_phone_number.replaceFirst("+", "");
    });

    try {
      final response = await http.get(
        Uri.parse("http://$ip:8000/chats/user-chat/$user_phone_number/$doc_phone_number/"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_chats_history = jsonResponse.map((data) => chat_history.fromJson(data)).toList();
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

  Future<void> _create_chats_two(BuildContext context) async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_number = perf.getString("doctor_phone_no") ?? "917845711277";
      doc_phone_number = doc_phone_number.replaceFirst("+", "");
    });


    try {
      final String uploadUrl = 'http://$ip:8000/chats/send-message/';

      // Prepare the multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add fields
      request.fields['sender_phone'] = doc_phone_number;
      request.fields['receiver_phone'] = "${get_user_number!.phoneNumber}";
      request.fields['message'] = messageController.text; // Default message if empty
      request.fields['sender_type'] = sender_type;

      // Add image if available
      if (kIsWeb && webImage != null) {
        // Web platform: Add image from Uint8List
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            webImage!,
            filename: 'image.png',
          ),
        );
        print('Added web image to request');
      } else if (!kIsWeb && img != null) {
        // Mobile platform: Add image from File
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            img!.path,
            filename: basename(img!.path),
          ),
        );
        print('Added mobile image to request');
      }

      // Debug request content
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');

      // Send the request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        await _get_user_doctor_chat_history();
        NotificationService().showNotification(
          id: 0,
          title: "Health hub",
          body:
          "you: ${messageController.text.isNotEmpty ? messageController.text : 'Image sent'}",
        );
        messageController.clear();
        setState(() {
          img = null; // Clear image after sending
          webImage = null; // Clear web image
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
        Future.delayed(Duration(milliseconds: 100), () {
          print(
              "Delayed check: Current position: ${_scrollController.position.pixels}, Max extent: ${_scrollController.position.maxScrollExtent}");
          _scrollToBottom();
        });
      } else {
        print('API error: $responseBody');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Send Failed"),
            content: Text(
                "Error: ${responseBody.isNotEmpty ? responseBody : 'Unknown error'}"),
          ),
        );
      }
    } catch (e) {
      errormessage = e.toString();
      print("Error: $errormessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $errormessage')),
      );
    }
  }
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        // For Mobile
        setState(() {
          img = io.File(pickedFile.path);
        });
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _get_user_phone_no() async {
    final url = Uri.parse("http://$ip:8000/user_profile/user_edit/$user_phone_number/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_user_number = update_profile.fromJson(jsonResponse);
          isloading = false;
        });
      } else {
        setState(() {
          errormessage = "failed to load user details";
          isloading = false;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      isloading = false;
    }
  }


  Future<void> _doc_offline() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no")??"";
      doc_phone_no=doc_phone_no.replaceFirst("+", "");
      print("$doc_phone_no");
    });
    try{
      final response = await http.put(Uri.parse("http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({"doc_status": false}),
      );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: get_user_number != null && get_user_number!.userPhoto != null
                  ? NetworkImage("http://$ip:8000${get_user_number!.userPhoto}")
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: get_user_number != null
                  ? Text(
                  "${get_user_number!.firstName ?? "No name"} ${get_user_number!.lastName}",
                  style: TextStyle(fontWeight: FontWeight.bold))
                  : CircularProgressIndicator(),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>only_photo(
                  doc_phone:"${doc_phone_number}", pati_phone:"$user_phone_number",user_type: "doctor",)));
              }, icon: Icon(Icons.photo)),
              IconButton(
                  onPressed: () {
                    _launchPhoneDialer();
                  },
                  icon: Icon(Icons.call)),

            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => search_chat_doc(
                            data: "${widget.data}",
                          )));
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
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isloading
                ? Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
              height: 100,))
                : ListView.builder(
              controller: _scrollController,
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
                  text: chat.message,
                  senderType: chat.senderType,
                  time: chat.timestamp,
                  id: chat.id,
                  image: chat.image,
                  date: chat.datestamp,
                  showDate: showDate,
                )
                    : Text("data");
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                img == null
                    ? SizedBox()
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap:(){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>photos_vies(photo_view: img as File,)));
                        },
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.black, width: 1),
                            image: DecorationImage(
                              image: img != null
                                  ? FileImage(img!) // For Mobile (File)
                                  : webImage != null
                                  ? MemoryImage(
                                  webImage!) // For Web (Uint8List)
                                  : NetworkImage(
                                  'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png')
                              as ImageProvider,
                              // Placeholder
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          left: 90,
                          top: -5,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  img = null;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              )))
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
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
                        onPressed: () {
                          _pickImage();
                        },
                        icon: Icon(Icons.photo)),
                    (messageController.text.trim().isEmpty && img==null)
                        ? SizedBox()
                        : IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          _create_chats_two(context);
                        }),
                  ],
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
  final dynamic id;
  final dynamic date;
  final dynamic image;
  final bool showDate; // New parameter to control date visibility

  ChatBubble(
      {required this.text,
        required this.senderType,
        required this.time,
        required this.id,
        required this.date,
        required this.showDate,
        required this.image});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  DateTime now = DateTime.now();
  String forr = "";
  String chattime = "";
  DateTime chatt = DateTime.now();

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
      } catch (e) {
        print("Error parsing time: $e");
      }
    });
  }

  Future<void> delete_chat_user_doc(int id)async{
    try{
      final response= await http.delete(Uri.parse("http://$ip:8000/chats/delete_chat_user_doc/$id/"));
      if(response.statusCode==200){
        print("delete successfully");
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = widget.senderType == 'doctor';
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
          child: Column(
            crossAxisAlignment:  isUser?CrossAxisAlignment.end :CrossAxisAlignment.start,
            children: [
              widget.image==null
                  ?SizedBox()
                  :Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onLongPress: (){
                    isUser
                        ?showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Notice!",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            "Did you want to delete this chat!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.red),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      delete_chat_user_doc(widget.id);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.green),
                                    )),
                              ],
                            )
                          ],
                        )):SizedBox();

                  },
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_view(doc_photo: "${widget.image}",)));
                  },
                  child: Container(
                      clipBehavior: Clip.hardEdge,
                      // height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        // border: Border.all(color: isUser ? Colors.blue : Colors.grey,width: 2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: isUser ? Radius.circular(15) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : Radius.circular(15),
                        ),
                      ),
                      child: Image.network(

                        // scale: 1,
                          fit: BoxFit.cover,
                          "http://$ip:8000${widget.image}")
                  ),
                ),
              ),
              widget.text==""||widget.text==null
              ?SizedBox()
              :GestureDetector(
                onLongPress: (){
                  isUser
                      ?showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          "Notice!",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          "Did you want to delete this chat!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 20),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.red),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    delete_chat_user_doc(widget.id);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.green),
                                  )),
                            ],
                          )
                        ],
                      )):SizedBox();

                },
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
            ],
          ),
        ),
        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15),
            child: Text(chattime, style: TextStyle(fontSize: 10)),
          ),
        ),
      ],
    )
        : Text("No chat, Start chatting!");
  }
}
