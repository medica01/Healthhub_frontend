import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/pages/Booking_history/booking_history_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:health_hub/pages/home_page/all_doctor_2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Backend_doctor_details.dart';

class doc_profile extends StatefulWidget {
  final dynamic data;

  doc_profile({super.key, required this.data});

  @override
  State<doc_profile> createState() => _doc_profileState();
}

class _doc_profileState extends State<doc_profile> {
  bool heart = false;
  List<doctor_details> doctor_detail = [];
  bool isLoading = true;
  String? errorMessage;
  String? pk;
  DateTime now = DateTime.now();
  int selectedDateIndex = -1;
  int selectedTimeIndex = -1;
  String selectedDate = "";
  String selectedTime = "";
  String user_phone = "";
  List<Map<String, String>> next7Days = [];

  Future<void> _booking_doc() async {
    String? doc_id = pk;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? book_date = selectedDate;
    String? book_time = selectedTime;
    setState(() {
      user_phone = pref.getString('phone_number') ?? "917845711277";
      user_phone = user_phone.replaceFirst('+', '');
      // book_date = book_date.replaceFirst("Fri - 21 Feb", "to")
    });

    try {
      final response = await http.post(
        Uri.parse("http://$ip:8000/booking_doctor/create_book_doc/"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          'id': doc_id,
          'phone_number': user_phone,
          'booking_date':book_date,
          'booking_time':book_time
        })
      );
      if(response.statusCode==201){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>booking_history_page()));
      }
      else{
      //   print('your booking failed:${response.body}');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("your booking failed${response.body}")),);
        showDialog(context: context, builder: (context)=>AlertDialog(
          title: Text("Booking failed",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 20),),
          content: Text("Your booking faild please re-book this doctor"),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Ok",style: TextStyle(color: Color(0xff1f8acc)),))
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

  List<String> getWorkingHours(bool isToday) {
    List<String> workingHours = [];
    int currentHour = now.hour;
    int startHour = isToday
        ? (currentHour + 1)
        : 5; // Next available hour if today, otherwise 5 AM
    int endHour = 22; // 10 PM

    for (int hour = startHour; hour <= endHour; hour++) {
      DateTime time = DateTime(now.year, now.month, now.day, hour, 0);
      workingHours.add(DateFormat('h:mm a').format(time));
    }
    return workingHours;
  }

  List<Map<String, String>> getNext7Days() {
    return List.generate(7, (index) {
      // DateTime nextDay = now.add(Duration(days: index + 1));
      DateTime nextDay = now.add(Duration(days: index));
      return {
        'date': DateFormat('dd MMM').format(nextDay),
        'year': DateFormat('yyyy').format(nextDay),
        'day': DateFormat('EE').format(nextDay), // Get full day name
      };
    });
  }

  @override
  void initState() {
    super.initState();
    pk = widget.data;
    _showdoctor();
    next7Days = getNext7Days();
  }

  Future<void> _showdoctor() async {
    final url = Uri.parse(
        "http://$ip:8000/doctor_details/doctor_editdetails/$pk/"); // Specific doctor's details
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Assuming the response is a single JSON object, not a list
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          doctor_detail = [doctor_details.fromJson(jsonResponse)];
          isLoading = false;
        });
        print(jsonResponse); // Log raw JSON response
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

  @override
  Widget build(BuildContext context) {
    bool isToday =
        selectedDateIndex == 0; // Check if the selected date is today
    List<String> workingHours = getWorkingHours(isToday);

    final scr = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor's Profile"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.share))],
      ),
      body: Stack(
        children: [
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: doctor_detail.length,
            itemBuilder: (context, index) {
              var doctor = doctor_detail[index];
              return doctor.id != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  doctor.doctorImage != null
                                      ? "http://$ip:8000${doctor.doctorImage}"
                                      : "no data",
                                  scale: 5,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        doctor.doctorName ?? "Unknown",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                      Text(
                                        doctor.specialty ?? "No qualification",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text("${doctor.service} years of exp"),
                                      Text(doctor.language ?? "Tamil"),
                                      Text(doctor.doctorLocation ?? "Chennai"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          next7Days.length,
                                          (index) => GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedDateIndex =
                                                    index; // Update selected date index
                                                selectedDate =
                                                    "${next7Days[selectedDateIndex]['day']} - ${next7Days[selectedDateIndex]['date']}";
                                                print("$selectedDate");
                                              });
                                            },
                                            child: Container(
                                              height: 90,
                                              width: 70,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedDateIndex == index
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
                                                    // Show day name
                                                    style: TextStyle(
                                                      color:
                                                          selectedDateIndex ==
                                                                  index
                                                              ? Colors.white
                                                              : Color(
                                                                  0xff1f8acc),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8.0),
                                                    child: Text(
                                                      next7Days[index]['date']!,
                                                      // Show date
                                                      style: TextStyle(
                                                        color:
                                                            selectedDateIndex ==
                                                                    index
                                                                ? Colors.white
                                                                : Color(
                                                                    0xff1f8acc),
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
                                    // if (selectedDateIndex != -1) // Show selected date below
                                    //  Text(
                                    //    'Selected Date: ${next17Days[selectedDateIndex]['day']} - ${next17Days[selectedDateIndex]['date']}',
                                    //    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    //  ),
                                    Text(
                                      "Select ",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    // if (selectedDateIndex != -1)
                                    selectedDateIndex == 0
                                        ? Center(
                                            child: Text(
                                            "Working hour only 5 am to 10 pm",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ))
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
                                                        selectedTimeIndex =
                                                            index;
                                                        selectedTime =
                                                            workingHours[index];
                                                        print(
                                                            "Selected Time: $selectedTime");
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 50,
                                                      width: 90,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 7),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            selectedTimeIndex ==
                                                                    index
                                                                ? Color(
                                                                    0xff1f8acc)
                                                                : Colors
                                                                    .transparent,
                                                        border: Border.all(
                                                            color: Color(
                                                                0xff1f8acc),
                                                            width: 1.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          workingHours[index],
                                                          style: TextStyle(
                                                            color: selectedTimeIndex ==
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
                          padding: EdgeInsets.only(top: 28.0, left: 15),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "About Doctor",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(doctor.bio ?? "no bio")
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 28.0, left: 15),
                          child: Text(
                            "Treatment and producedures",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 15),
                          child: Text(doctor.specialty ?? "no report"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 28.0, left: 15),
                          child: Text(
                            "Registration",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 15),
                          child: Text("${doctor.regNo}" ?? "no report"),
                        ),
                        Container(
                          height: 200,
                        )
                      ],
                    )
                  : const Text("No data available");
            },
          ),
          Positioned(
            bottom: 80,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  _booking_doc();
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.92,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text(
                      "Book Free Consult",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
