import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Notification_services.dart';
import 'package:health_hub/user%20app/pages/Profile_page/personal_details_collect.dart';
import 'package:health_hub/user%20app/pages/message_page/search_chat.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/chat_history_backend.dart';
import '../../../Backend_information/on_off_backend.dart';
import '../../../Doctor app/pages/Doc_message_page/chat_photo_only.dart';
import '../../../main.dart';
import '../../Other_feature/photo_view.dart';
import '../Profile_page/profile_photo_2.dart';
import '../home_page/doctor_profile_3.dart';
import 'package:path/path.dart';

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
  final ScrollController _scrollController = ScrollController();
  String sources = "";
  final _picker = ImagePicker();
  Uint8List? webImage;
  io.File? img;

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
    _get_user_doctor_chat_history().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
    messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _user_offline();
    _scrollController.dispose();
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      double maxExtent = _scrollController.position.maxScrollExtent;
      double currentPosition = _scrollController.position.pixels;
      print("Current position: $currentPosition, Max extent: $maxExtent");
      if (maxExtent > 0) {
        _scrollController.animateTo(
          maxExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        print("Scrolled to bottom.");
      } else {
        print("No scrolling needed, list fits on screen.");
      }
    } else {
      print("ScrollController not attached yet.");
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

  Future<void> _create_chat_two(BuildContext context) async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });

    try {
      final String uploadUrl = 'http://$ip:8000/chats/send-message/';

      // Prepare the multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add fields
      request.fields['sender_phone'] = phone_number;
      request.fields['receiver_phone'] = "${get_doc_number!.doctorPhoneNo}";
      request.fields['message'] =
          messageController.text; // Default message if empty
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: get_doc_number != null &&
                      get_doc_number!.doctorImage != null
                  ? NetworkImage(
                      "http://$ip:8000${get_doc_number!.doctorImage}")
                  : NetworkImage(
                          'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png')
                      as ImageProvider, // Use a default image
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: get_doc_number != null
                  ? Text("${get_doc_number!.doctorName ?? "No name"}",
                      style: TextStyle(fontWeight: FontWeight.bold))
                  : SizedBox(), // Show a loader until data is loaded
            ),
            // Text("Online", style: TextStyle(
            //     color: Colors.green, fontWeight: FontWeight.bold),)
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => only_photo(
                              doc_phone: "${get_doc_number!.doctorPhoneNo}",
                              pati_phone: phone_number,
                              user_type: "user",
                            )));
              },
              icon: Icon(Icons.photo)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => doc_profile(
                              data: "${get_doc_number!.id}",
                            )));
              },
              icon: Icon(Icons.calendar_month)),
          IconButton(
              onPressed: () {
                _launchPhoneDialer();
              },
              icon: Icon(Icons.call))
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
                ? Center(child: Lottie.asset("assets/lottie/ani.json",width: 100,
              height: 100,))
                : (get_chat_history.isNotEmpty
                ?ListView.builder(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: get_chat_history.length,
                    itemBuilder: (context, index) {
                      var chat = get_chat_history[index];
                      bool showDate = index == 0 || // First message
                          get_chat_history[index].datestamp !=
                              get_chat_history[index - 1].datestamp; // New day
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
                              date: chat.datestamp,
                              image: chat.image,
                              id: chat.id,
                              showDate: showDate,
                            )
                          : Text("data");
                    },
                  ):Center(child: Text("No chat, Start chatting!",style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),))),
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
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => photos_vies(
                                              photo_view: img as io.File,
                                            )));
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
                    (messageController.text.trim().isEmpty && img == null)
                        ? SizedBox()
                        : IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              _create_chat_two(context);
                              _create_chat_doc_only_user_chat();
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
  final dynamic id;
  final dynamic senderType;
  final dynamic time;
  final dynamic date;
  final dynamic image;
  final bool showDate; // New parameter to control date visibility

  ChatBubble(
      {required this.text,
      required this.senderType,
      required this.time,
      required this.date,
      required this.showDate,
        required this.id,
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
    bool isUser = widget.senderType == 'user';
    return widget.id!=''||widget.id!=null
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
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    widget.image == null
                        ? SizedBox()
                        : Padding(
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
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => pati_view(
                                              pati_views: "${widget.image}",
                                            )));
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
                                      bottomLeft: isUser
                                          ? Radius.circular(15)
                                          : Radius.zero,
                                      bottomRight: isUser
                                          ? Radius.zero
                                          : Radius.circular(15),
                                    ),
                                  ),
                                  child: Image.network(

                                      // scale: 1,
                                      fit: BoxFit.cover,
                                      "http://$ip:8000${widget.image}")),
                            ),
                          ),
                    widget.text == "" || widget.text == null
                        ? SizedBox()
                        : GestureDetector(
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
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color:
                                    isUser ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft:
                                      isUser ? Radius.circular(15) : Radius.zero,
                                  bottomRight:
                                      isUser ? Radius.zero : Radius.circular(15),
                                ),
                              ),
                              child: Text(widget.text,
                                  style: TextStyle(fontSize: 16)),
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
