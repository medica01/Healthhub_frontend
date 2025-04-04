import 'dart:convert';
import 'dart:io' show Platform;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_Booking_patient_history/Doc_booking_patient_history.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_Booking_patient_history/specific_patient_details.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_home_page/Doc_home_page.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_locations_page/doc_location_page.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_message_page/doc_message_page.dart';
import 'package:health_hub/Doctor%20app/pages/Doc_profile_page/doc_profile_page.dart';
import 'package:http/http.dart%20' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Backend_information/Backend_doctor_details.dart';
import '../main.dart';
import '../user app/medicine_page/pages/medical_home.dart';

//
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _selectedIndex = 2;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   void _onNavRailTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       _tabController.animateTo(index);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Colors.white10,
//         body: Row(
//           children: [
//             if (kIsWeb) // Show NavigationRail for Web
//               NavigationRail(
//                 selectedIndex: _selectedIndex,
//                 onDestinationSelected: _onNavRailTapped,
//                 labelType: NavigationRailLabelType.all,
//                 destinations: [
//                   NavigationRailDestination(
//                     icon: Icon(FontAwesomeIcons.location),
//                     label: Text('Location'),
//                   ),
//                   NavigationRailDestination(
//                     icon: Icon(Icons.message_outlined),
//                     label: Text('Messages'),
//                   ),
//                   NavigationRailDestination(
//                     icon: Icon(Icons.home),
//                     label: Text('Home'),
//                   ),
//                   NavigationRailDestination(
//                     icon: Icon(Icons.person),
//                     label: Text('Profile'),
//                   ),
//                   NavigationRailDestination(
//                     icon: Icon(Icons.history),
//                     label: Text('History'),
//                   ),
//                 ],
//               ),
//             Expanded(
//               child: TabBarView(
//                 physics: NeverScrollableScrollPhysics(),
//                 controller: _tabController,
//                 children: [
//                   doc_location(),
//                   doc_message(),
//                   doc_home(),
//                   doc_profiles(),
//                   doc_book_pati(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: !kIsWeb
//             ? BottomNavigationBarWidget(controller: _tabController)
//             : null,
//       ),
//     );
//   }
// }
//
// class BottomNavigationBarWidget extends StatelessWidget {
//   final TabController controller;
//   const BottomNavigationBarWidget({required this.controller, Key? key})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       child: Stack(
//         children: [
//           CustomPaint(
//             size: Size(MediaQuery.of(context).size.width, 80),
//             painter: BottomNavigationBarPainter(),
//           ),
//           Center(
//             heightFactor: 0.1,
//             child: FloatingActionButton(
//               onPressed: () {
//                 controller.animateTo(2);
//               },
//               backgroundColor: Color(0xff1f8acc),
//               child: Icon(Icons.home, color: Colors.white),
//               elevation: 1.5,
//             ),
//           ),
//           Positioned.fill(
//             child: TabBar(
//               controller: controller,
//               labelColor: Color(0xff1f8acc),
//               unselectedLabelColor: Colors.black,
//               indicatorColor: Colors.transparent,
//               tabs: [
//                 Tab(icon: Icon(FontAwesomeIcons.location)),
//                 Tab(icon: Icon(Icons.message_outlined)),
//                 Container(width: 40),
//                 Tab(icon: Icon(Icons.person)),
//                 Tab(icon: Icon(Icons.history)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BottomNavigationBarPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//     Path path = Path();
//     path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
//     path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
//     path.arcToPoint(Offset(size.width * 0.60, 20),
//         radius: Radius.circular(40.0), clockwise: false);
//     path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
//     path.quadraticBezierTo(size.width * 0.80, 0, size.width, 0);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
class docHomePage extends StatefulWidget {
  const docHomePage({super.key});

  @override
  State<docHomePage> createState() => _docHomePageState();
}

class _docHomePageState extends State<docHomePage> {
  String errormessage = "";
  doctor_details? get_doc_details;
  String doc_phone_no = "";
  bool isloading = false;
  List<booking_doctor> booking_doc_user = [];
  DateTime now = DateTime.now();
  String todate = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_doctor_details();
    _show_booked_user();
    todate = DateFormat('yyyy-MMM-dd-EEE').format(now);
    print("${todate}");
  }

  Future<void> _show_booked_user() async {
    String doc_phone_number = "";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_number = pref.getString('doctor_phone_no') ?? "";
      doc_phone_number = doc_phone_number.replaceFirst("+", "");
      print("$doc_phone_number");
    });
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/booking_doctor/spec_doctor_booked/$doc_phone_number/"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          booking_doc_user = jsonResponse
              .map((data) => booking_doctor.fromJson(data))
              .toList();
          print("${booking_doc_user.length}");
          isloading = true;
        });
      } else {
        setState(() {
          errormessage = "failed to load user details";
          isloading = true;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      print("${errormessage}");
      isloading = true;
    }
  }

  Future<void> _get_doctor_details() async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no") ?? "";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
      print("$doc_phone_no");
    });
    try {
      final response = await http.get(
        Uri.parse(
            "http://$ip:8000/doctor_details/doc_editdetails_phone/$doc_phone_no/"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_doc_details = doctor_details.fromJson(jsonResponse);
        });
      }
    } catch (e) {
      errormessage = e.toString();
      print("${errormessage}");
      isloading = true;
    }
  }

  final List<String> images = [
    "https://static.vecteezy.com/system/resources/previews/016/699/936/non_2x/book-doctor-appointment-online-flat-banner-template-making-visit-poster-leaflet-printable-color-designs-editable-flyer-page-with-text-space-vector.jpg",
    // "https://img.freepik.com/free-psd/medical-business-social-media-promo-template_23-2149488299.jpg?uid=R162018176&ga=GA1.1.249085122.1736660184&semt=ais_incoming",
    // "https://img.freepik.com/free-psd/medical-business-horizontal-banner-template_23-2149488295.jpg?uid=R162018176&ga=GA1.1.249085122.1736660184&semt=ais_incoming"
  ];

  Widget one(String txt, IconData ic) {
    return Container(
      height: 70,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ic,
            color: Colors.blueAccent,
            size: 30,
          ),
          Padding(
            padding: EdgeInsets.only(top: 18.0),
            child: Container(child: Text(txt)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return get_doc_details != null
        ? Scaffold(
            appBar: AppBar(
              leadingWidth: 1000,
              leading: Builder(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 22.0,
                          backgroundImage: get_doc_details!.doctorImage != null
                              ? NetworkImage(
                                  "http://$ip:8000${get_doc_details!.doctorImage}")
                              : NetworkImage(""),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, Welcome,",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            get_doc_details!.doctorName != null
                                ? Text(
                                    "${get_doc_details!.doctorName}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text("Guest",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              actions: [
                IconButton(
                    onPressed: () {}, icon: Icon(Icons.notifications_active))
              ],
            ),
            drawer: AppDrawer(),
            body: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                clipBehavior: Clip.hardEdge,
                children: [
                  CarouselSlider(
                    items: images
                        .map((imagePath) => ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ))
                        .toList(),
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 5),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      clipBehavior: Clip.hardEdge,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 40, bottom: 20),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                doc_message()));
                                  },
                                  child: one("Message", Icons.message)),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                doc_book_pati()));
                                  },
                                  child: one("Appointment",
                                      FontAwesomeIcons.bookmark)),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                doc_profiles()));
                                  },
                                  child: one("Doctor plan", Icons.event_note)),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  doc_location()));
                                    },
                                    child: one(
                                        "Location", Icons.location_on_sharp)),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Medical_main_page()));
                                    },
                                    child: one("Medicine",
                                        FontAwesomeIcons.kitMedical)),
                                // one("Message", Icons.message),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Today Appointments",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: booking_doc_user.map((show_book) {
                        return show_book.bookingDate == todate
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              specific_patient(
                                                  user_id: "${show_book.id}")));
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
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    height: 190,
                                    width: 330,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10.0, top: 15, bottom: 15),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                                radius: 50,
                                                backgroundImage: NetworkImage(
                                                  show_book.userPhoto != null
                                                      ? "http://$ip:8000${show_book.userPhoto}"
                                                      : "no data ",
                                                )),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 28.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${show_book.firstName} ${show_book.lastName}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5.0),
                                                    child: Text(
                                                      "age:${show_book.age}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5.0),
                                                    child: Text(
                                                      "gender: ${show_book.gender}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5.0),
                                                    child: Text(
                                                      "date: ${show_book.bookingDate}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5.0),
                                                    child: Text(
                                                      "time: ${show_book.bookingTime}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
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
                            : SizedBox();
                      }).toList(), // <-- fix applied here
                    ),
                  ),
                  Container(
                    height: 100,
                  )
                ],
              ),
            ),
          )
        : Center(child: Container(child: CircularProgressIndicator()));
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Welcome Gokul!',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
