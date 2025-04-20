
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Backend_information/user_details_backend.dart';
import 'package:health_hub/Doctor%20app/doctor_homepage.dart';
import 'package:health_hub/user%20app/pages/Profile_page/profile_page.dart';
import 'package:health_hub/user%20app/pages/home_page/hoem_page.dart';
import 'package:http/http.dart%20' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../pages/home.dart';
import 'Med_home_page/med_home_page.dart';
import 'Order_show/Order_show.dart';
import 'add_to_cart/show_add_to_cart.dart';

class Medical_main_page extends StatefulWidget {
  const Medical_main_page({super.key});

  @override
  State<Medical_main_page> createState() => _Medical_main_pageState();
}

class _Medical_main_pageState extends State<Medical_main_page>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2;
  String phone_number = "";
  bool doc_or_use = false;
  bool use_or_doc = false;

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

  void _onNavRailTapped(int index) async {
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_or_use = perf.getBool("doc_login") ?? false;
      use_or_doc = perf.getBool("login") ?? false;
    });
    if (doc_or_use == true) {
      if (index == 0) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => docHomePage()),
            (route) => false);
      } else {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(index);
        });
      }
    } else if (use_or_doc == true) {
      if (index == 0) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);
      } else {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(index);
        });
      }
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
            if (kIsWeb) // Show NavigationRail for Web
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavRailTapped,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.arrow_back),
                    label: Text('back'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    label: Text('Account'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(FontAwesomeIcons.houseMedical),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Cart'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_shipping_outlined),
                    label: Text('Order'),
                  ),
                ],
              ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  SizedBox(),
                  profile_page(),
                  medi_home_page(),
                  show_to_cart(),
                  show_order_placed()
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: !kIsWeb
            ? BottomNavigationBarWidget(controller: _tabController)
            : null,
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatefulWidget {
  final TabController controller;

  const BottomNavigationBarWidget({required this.controller, Key? key})
      : super(key: key);

  @override
  State<BottomNavigationBarWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  bool doc_or_use = false;
  bool use_or_doc = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: BottomNavigationBarPainters(),
          ),
          Center(
            heightFactor: 0.1,
            child: FloatingActionButton(
              onPressed: () {
                widget.controller.animateTo(2);
              },
              backgroundColor: Color(0xff1f8acc),
              child: Icon(FontAwesomeIcons.houseMedical, color: Colors.white),
              elevation: 1.5,
            ),
          ),
          Positioned.fill(
            child: TabBar(
              controller: widget.controller,
              labelColor: Color(0xff1f8acc),
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.transparent,
              tabs: [

                GestureDetector(
                  onTap: () async{
                    SharedPreferences perf = await SharedPreferences.getInstance();
                    setState(() {
                      doc_or_use = perf.getBool("doc_login") ?? false;
                      use_or_doc = perf.getBool("login") ?? false;
                    });
                    doc_or_use
                    ?Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => docHomePage()),
                    )
                        :Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                Tab(icon: Icon(Icons.group_add_rounded)),
                Container(width: 40),
                Tab(icon: Icon(Icons.shopping_cart)),
                Tab(icon: Icon(Icons.local_shipping_outlined)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavigationBarPainters extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    Path path = Path();
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(40.0), clockwise: false);
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
