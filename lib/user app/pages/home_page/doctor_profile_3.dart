import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/Notification_services.dart';
import 'package:health_hub/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../Backend_information/get_fav_doc_backend.dart';
import '../../medicine_page/pages/Med_home_page/order_successfully.dart';
import '../Profile_page/personal_details_collect.dart';
import '../Profile_page/profile_page.dart';
import '../message_page/chatting_user_to_doc_2.dart';

class ghghghg {
  int? id;
  String? userName;
  String? feedback;

  ghghghg({this.id, this.userName, this.feedback});

  ghghghg.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    feedback = json['feedback'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_name'] = this.userName;
    data['feedback'] = this.feedback;
    return data;
  }
}


class doc_profile extends StatefulWidget {
  final dynamic data;

  doc_profile({super.key, required this.data});

  @override
  State<doc_profile> createState() => _doc_profileState();
}

class _doc_profileState extends State<doc_profile> {
  update_profile? userprofile;
  bool heart = false;
  doctor_details? doctor_detail;
  bool isLoading = true;
  String? errorMessage;
  String? pk;
  DateTime now = DateTime.now();
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;
  String selectedDate = "";
  String selectedTime = "";
  String user_phone = "";
  List<Map<String, String>> next7Days = [];
  String phone_number = "";
  List<booking_doctor> booking_doc_user = [];
  get_fav_doc? get_fav_doctor;

  List<ghghghg> get_feed=[];


  Future<void> _booking_doc() async {
    String? doc_id = pk;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? book_date = selectedDate;
    String? book_time = selectedTime;
    setState(() {
      user_phone = pref.getString('phone_number') ?? "917845711277";
      user_phone = user_phone.replaceFirst('+', '');
    });

    try {
      final response = await http.post(
          Uri.parse(
              "http://$ip:8000/booking_doctor/create_booking_doctor_user/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'id': doc_id,
            'phone_number': user_phone,
            'booking_date': book_date,
            'booking_time': book_time
          }));
      if (response.statusCode == 201) {
        _vibrate();
        _create_chat_doc_only_user_chat();
        _create_booked_doc_chat();
        showBottomSheet(
            context: context, builder: (context) => Booking_success());
        await _show_booked_user();
        NotificationService().showNotification(
            id: 0,
            title: "Health hub",
            body:
                "Dr ${doctor_detail!.doctorName} Appointment Successfully Booking \nDate: $book_date \nTime: $book_time");
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Booking failed",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  content: Text("This slot is already booked"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Ok",
                          style: TextStyle(color: Color(0xff1f8acc)),
                        ))
                  ],
                ));
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<void> _create_chat_doc_only_user_chat() async {
    String doc_phone_number = "${doctor_detail!.doctorPhoneNo}";
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
        print("The user successfully added to doctor chat");
      } else {
        print("The user failed to add to the doctor chat");
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  Future<void> _create_booked_doc_chat() async {
    String doc_phone_number = "${doctor_detail!.doctorPhoneNo}";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number") ?? "";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.post(
          Uri.parse("http://$ip:8000/booking_doctor/create_booked_doc_chat/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "patient_phone_number": phone_number,
            "doctor_phone_no": doc_phone_number
          }));
      if (response.statusCode == 201) {
        print("The doctor successfully added to user chat");
      } else {
        print("The doctor failed to add to the user chat");
      }
    } catch (e) {
      print("${e.toString()}");
    }
  }

  List<String> getWorkingHours(bool isToday, String selectedDate) {
    List<String> workingHours = [];
    int currentHour = now.hour;
    int startHour = isToday ? (currentHour + 2) : 5;
    int endHour = 22;

    if (startHour > endHour) startHour = endHour;

    for (int hour = startHour; hour <= endHour; hour++) {
      DateTime time = DateTime(now.year, now.month, now.day, hour, 0);
      String formattedTime = DateFormat('h:mm a').format(time);

      // Check if this time is blocked for the selected date
      bool isBlocked = blockedSlots.any((slot) =>
          slot['date']!.toLowerCase() == selectedDate.toLowerCase() &&
          slot['time'] == formattedTime);

      if (!isBlocked) {
        workingHours.add(formattedTime);
      }
    }

    return workingHours;
  }

  List<Map<String, String>> getNext7Days() {
    return List.generate(7, (index) {
      DateTime nextDay = now.add(Duration(days: index));
      return {
        'date': DateFormat('MMM dd').format(nextDay),
        'year': DateFormat('yyyy').format(nextDay),
        'day': DateFormat('EE').format(nextDay),
      };
    });
  }

  Future<void> userpro() async {
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.get(
          Uri.parse("http://$ip:8000/user_profile/user_edit/$phone_number/"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          userprofile = update_profile.fromJson(jsonResponse);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.body.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
  }

  Future<void> getfeed() async {

    try {
      final response = await http.get(
          Uri.parse("http://$ip:8000/chats/get_feed/"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_feed = jsonResponse.map((data)=>ghghghg.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.body.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    getfeed();
    pk = widget.data;

    // Populate next7Days first
    next7Days = getNext7Days();

    // Set default date and time
    selectedDateIndex = 0;
    selectedDate =
        "${next7Days[0]['year']}-${next7Days[0]['date']}-${next7Days[0]['day']}"
            .replaceFirst(" ", "-");

    bool isToday = selectedDateIndex == 0;
    List<String> workingHours = getWorkingHours(isToday, selectedDate);

    selectedTimeIndex = 0;
    selectedTime = workingHours.isNotEmpty ? workingHours[0] : "";

    // Proceed with other initialization
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _showdoctor();
      if (doctor_detail != null) {
        await _show_booked_user();
        _show_favorite_doc();
      }
      await userpro();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _show_booked_user() async {
    String doc_phone_number = "${doctor_detail!.doctorPhoneNo}";
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/booking_doctor/spec_doctor_booked/$doc_phone_number/"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          booking_doc_user = jsonResponse
              .map((data) => booking_doctor.fromJson(data))
              .toList();
          // blockedSlots = booking_doc_user
          //     .map((slot) => {
          //   'date': slot.bookingDate as String,
          //   'time': slot.bookingTime as String,
          // })
          //     .toList();
          print("${booking_doc_user.length}");
        });
      } else {
        setState(() {
          errorMessage = "Failed to load booked user details";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _showdoctor() async {
    final url =
        Uri.parse("http://$ip:8000/doctor_details/doctor_editdetails/$pk/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          doctor_detail = doctor_details.fromJson(jsonResponse);
          isLoading = false;
        });

        print(jsonResponse);
      } else {
        setState(() {
          errorMessage = "Failed to load doctor details.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }



  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  void valid_user() {
    if (userprofile!.firstName == null) {
      print("${userprofile!.firstName}");
      if (userprofile!.lastName == null) {
        if (userprofile!.age == null) {
          if (userprofile!.gender == null) {
            if (userprofile!.email == null) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                          "Invalid User",
                          style: TextStyle(color: Colors.red, fontSize: 25),
                        ),
                        content: Text(
                          "You must create an account to book!",
                          style: TextStyle(fontSize: 20),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) => SaveDetails());
                              },
                              child: Text("Ok"))
                        ],
                  ));
            }
          }
        }
      }
    } else {
      _booking_doc();
    }
  }

  void vvalid_user() {
    if (userprofile!.firstName == null) {
      print("${userprofile!.firstName}");
      if (userprofile!.lastName == null) {
        if (userprofile!.age == null) {
          if (userprofile!.gender == null) {
            if (userprofile!.email == null) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      "Invalid User",
                      style: TextStyle(color: Colors.red, fontSize: 25),
                    ),
                    content: Text(
                      "you must create the account for make favorite!",
                      style: TextStyle(fontSize: 20),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => profile_page()));
                          },
                          child: Text("Ok"))
                    ],
                  ));
            }
          }
        }
      }
    } else {
      _favorite_doctor();
    }
  }

  void vvvalid_user() {
    if (userprofile!.firstName == null) {
      print("${userprofile!.firstName}");
      if (userprofile!.lastName == null) {
        if (userprofile!.age == null) {
          if (userprofile!.gender == null) {
            if (userprofile!.email == null) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      "Invalid User",
                      style: TextStyle(color: Colors.red, fontSize: 25),
                    ),
                    content: Text(
                      "you must create the account for make favorite!",
                      style: TextStyle(fontSize: 20),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => profile_page()));
                          },
                          child: Text("Ok"))
                    ],
                  ));
            }
          }
        }
      }
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  user_doc(data: "${doctor_detail!.doctorPhoneNo}")));
    }
  }

  List<Map<String, String>> blockedSlots = [
    {'date': '2025-Apr-08-Tue', 'time': '1:00 PM'},
    {'date': '2025-Apr-08-Tue', 'time': '2:00 PM'},
  ];

  // New method to block a specific date and time
  void blockSpecificDateTime(String date, String time) {
    setState(() {
      // Add the date and time to blockedSlots
      blockedSlots.add({'date': date, 'time': time});

      // Refresh the working hours for the selected date
      bool isToday = selectedDateIndex == 0;
      List<String> updatedWorkingHours = getWorkingHours(isToday, selectedDate);

      // If the selected time is now blocked, select a new time (if available)
      if (selectedTime == time && updatedWorkingHours.isNotEmpty) {
        selectedTimeIndex = 0;
        selectedTime = updatedWorkingHours[0];
      } else if (updatedWorkingHours.isEmpty) {
        selectedTime = "";
        selectedTimeIndex = -1;
      }
    });
  }



  Future<void> _favorite_doctor() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.post(
          Uri.parse("http://$ip:8000/booking_doctor/create_favorite_doc/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id": doctor_detail!.id,
            "like": true,
            "phone_number": phone_number
          }));
      if (response.statusCode == 201) {
        _show_favorite_doc();
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Alert",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    "This Doctor already marked as a favorite",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                ));
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  "Alert",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                content: Text("$e"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("ok"))
                ],
              ));
    }
  }

  Future<void> _delete_fav() async{
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try{
      final response = await http.delete(Uri.parse("http://$ip:8000/booking_doctor/delete_fav_doc/$phone_number/${doctor_detail!.id}/"));
      if(response.statusCode==204){
        _show_favorite_doc();
      }
    }catch(e){
      print("${e.toString()}");
    }
  }

  Future<void> _show_favorite_doc() async {
    String phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phone_number = pref.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/booking_doctor/get_specific_fav_doc/$phone_number/${doctor_detail!.id}/"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_fav_doctor = get_fav_doc.fromJson(jsonResponse);
          print("${response.body}");
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "failed to load favorite doctor details";
          get_fav_doctor!.like=false;
          isLoading = false;
        });
      }
    } catch (e) {
      errorMessage = e.toString();
      print("$errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = selectedDateIndex == 0;
    List<String> workingHours = getWorkingHours(isToday, selectedDate);
    final scr = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor's Profile"),
        actions: [
          get_fav_doctor != null && get_fav_doctor!.like == true
              ? IconButton(
                  onPressed: () {
                    _delete_fav();
                  },
                  icon: Icon(
                    FontAwesomeIcons.solidHeart,
                    color: Colors.red,
                  ))
              : IconButton(
                  onPressed: () {
                    vvalid_user();
                  },
                  icon: Icon(FontAwesomeIcons.heart)),
          IconButton(
              onPressed: () {
                vvvalid_user();
              },
              icon: Icon(Icons.chat))
        ],
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
              "assets/lottie/ani.json",
              width: 100,
              height: 100,
            ))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  Center(
                    child: doctor_detail!.doctorImage != null
                        ? Image.network(
                            scale: 1,
                            "http://$ip:8000${doctor_detail!.doctorImage}")
                        : SizedBox(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "About Doctor",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name : ${doctor_detail!.doctorName}"),
                        Text("Specialist : ${doctor_detail!.specialty}"),
                        Text(
                            "Service : ${doctor_detail!.service} years of exp"),
                        Text("Age: ${doctor_detail!.age}"),
                        Text("Gender: ${doctor_detail!.gender}"),
                        Text("Know Language : ${doctor_detail!.language}"),
                        Text("Location : ${doctor_detail!.doctorLocation}"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "Select Date and Time",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Card(
                      color: Colors.white,
                      shadowColor: Colors.grey,
                      child: Container(
                        height: 280,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 18.0, bottom: 8, left: 8, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select date",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    next7Days.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedDateIndex = index;
                                          selectedDate =
                                              "${next7Days[index]['year']}-${next7Days[index]['date']}-${next7Days[index]['day']}"
                                                  .replaceFirst(" ", "-");
                                          bool isToday = selectedDateIndex == 0;
                                          List<String> updatedWorkingHours =
                                              getWorkingHours(
                                                  isToday, selectedDate);
                                          if (updatedWorkingHours.isNotEmpty) {
                                            selectedTimeIndex = 0;
                                            selectedTime =
                                                updatedWorkingHours[0];
                                          } else {
                                            selectedTimeIndex = -1;
                                            selectedTime = "";
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 90,
                                        width: 70,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selectedDateIndex == index
                                              ? Color(0xff1f8acc)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: Color(0xff1f8acc),
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              next7Days[index]['day']!,
                                              style: TextStyle(
                                                color:
                                                    selectedDateIndex == index
                                                        ? Colors.white
                                                        : Color(0xff1f8acc),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                next7Days[index]['date']!,
                                                style: TextStyle(
                                                  color:
                                                      selectedDateIndex == index
                                                          ? Colors.white
                                                          : Color(0xff1f8acc),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Select time",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              workingHours.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No available times for this date",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                            workingHours.length,
                                            (index) => GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedTimeIndex = index;
                                                  selectedTime =
                                                      workingHours[index];
                                                });
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 90,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7),
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedTimeIndex == index
                                                          ? Color(0xff1f8acc)
                                                          : Colors.transparent,
                                                  border: Border.all(
                                                      color: Color(0xff1f8acc),
                                                      width: 1.5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    workingHours[index],
                                                    style: TextStyle(
                                                      color:
                                                          selectedTimeIndex ==
                                                                  index
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff1f8acc),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "Treatment and Procedures",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${doctor_detail!.specialty}"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "Doctor Qualification",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${doctor_detail!.qualification}"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "Doctor Bio",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${doctor_detail!.bio}"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "Doctor Register number",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${doctor_detail!.regNo}"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      "feed back",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                  itemCount: get_feed.length,
                  itemBuilder: (context,index){
                      var feed=get_feed[index];
                    return feed !=null||feed.id!=null
                      ?Column(
                      children: [
                        Text("${feed.userName}"),
                        Text("${feed.feedback}"),
                      ],
                    ):Text("no data");
                  }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SizedBox(
                        height: 50,
                        width: 1000,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.blueAccent, width: 1),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              valid_user();
                              // Example: Block a specific date and time after booking (optional)
                              // blockSpecificDateTime("2025-Apr-06-Sun", "1:00 PM");
                            },
                            child: Text(
                              "Book Free Consult",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                  )
                ],
              ),
            ),
    );
  }
}
