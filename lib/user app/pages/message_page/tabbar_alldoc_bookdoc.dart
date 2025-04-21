import 'package:flutter/material.dart';
import 'package:health_hub/user%20app/pages/message_page/pati_chat_only_booking_doc.dart';

import 'message_page.dart';

class tab_alldoc_bookdoc extends StatefulWidget {
  const tab_alldoc_bookdoc({super.key});

  @override
  State<tab_alldoc_bookdoc> createState() => _tab_alldoc_bookdocState();
}

class _tab_alldoc_bookdocState extends State<tab_alldoc_bookdoc>with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController =TabController(length: 2, vsync: this,initialIndex: 0);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
        appBar: AppBar(
          backgroundColor: Colors.white54,
          centerTitle: true,
          title: Text("Message",style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 20),),
          bottom: TabBar(
              labelColor: const Color(0xff1f8acc),
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.transparent,
            controller: _tabController,
              tabs: [
            Tab(text: "All Doctor",),
            Tab(text: "Booking Doctor",)
          ]
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            message_page(),
            booking_doc_message()
          ],
        ),

    );
  }
}
