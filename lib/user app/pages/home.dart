import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../medicine_page/pages/Med_home_page/med_home_page.dart';
import '../medicine_page/pages/medical_home.dart';
import 'Booking_history/booking_history_page.dart';
import 'Profile_page/profile_page.dart';
import 'home_page/hoem_page.dart';
import 'locaton_page/location_page.dart';
import 'message_page/message_page.dart';
import 'message_page/tabbar_alldoc_bookdoc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavRailTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Medical_main_page()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
        _tabController.animateTo(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // backgroundColor: Colors.white10,
        body: Row(
          children: [
            if (kIsWeb)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavRailTapped,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(FontAwesomeIcons.location),
                    label: Text('Location'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.message_outlined),
                    label: Text('Messages'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(FontAwesomeIcons.kitMedical),
                    label: Text('Medicines'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history),
                    label: Text('History'),
                  ),
                ],
              ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  MapRouteApp(),
                  tab_alldoc_bookdoc(),
                  main_home(),
                  Medical_main_page(),
                  booking_history_page(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: !kIsWeb
            ? BottomNavigationBarWidgets(controller: _tabController)
            : null,
      ),
    );
  }
}

class BottomNavigationBarWidgets extends StatelessWidget {
  final TabController controller;

  const BottomNavigationBarWidgets({required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      height: 70,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: BottomNavigationBarPainter(),
          ),
          Center(
            heightFactor: 0.1,
            child: FloatingActionButton(
              onPressed: () {
                controller.animateTo(2);
              },
              backgroundColor: const Color(0xff1f8acc),
              child: const Icon(Icons.home, color: Colors.white),
              elevation: 1.5,
            ),
          ),
          Positioned.fill(
            child: TabBar(
              controller: controller,
              labelColor: const Color(0xff1f8acc),
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.transparent,
              tabs: [
                const Tab(icon: Icon(Icons.location_on_sharp)),
                const Tab(icon: Icon(Icons.message_outlined)),
                Container(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Medical_main_page()),
                    );
                  },
                  child: const Icon(FontAwesomeIcons.kitMedical),
                ),
                const Tab(icon: Icon(Icons.history)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    Path path = Path();
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: const Radius.circular(40.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

