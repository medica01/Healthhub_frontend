import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/user%20app/pages/home_page/hoem_page.dart';

import '../../pages/home.dart';
import 'Med_home_page/med_home_page.dart';
import 'Order_show/Order_show.dart';
import 'add_to_cart/show_add_to_cart.dart';


class Medical_main_page extends StatefulWidget {
  const Medical_main_page({super.key});

  @override
  State<Medical_main_page> createState() => _HomePageState();
}

class _HomePageState extends State<Medical_main_page>
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
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route)=>false);
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
        home:Scaffold(
        backgroundColor: Colors.white10,
        body: Row(
          children: [
            if (kIsWeb) // Show NavigationRail for Web
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavRailTapped,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
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
                  medi_home_page(),
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

    ),);
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final TabController controller;
  const BottomNavigationBarWidget({required this.controller, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              backgroundColor: Color(0xff1f8acc),
              child: Icon(Icons.home, color: Colors.white),
              elevation: 1.5,
            ),
          ),
          Positioned.fill(
            child: TabBar(
              controller: controller,
              labelColor: Color(0xff1f8acc),
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.transparent,
              tabs: [
                Tab(icon: Icon(FontAwesomeIcons.location)),
                Tab(icon: Icon(Icons.message_outlined)),
                Container(width: 40),
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.history)),
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