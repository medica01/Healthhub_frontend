import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_hub/Backend_information/Backend_booking_doctor.dart';
import 'package:health_hub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class booking_history_page extends StatefulWidget {
  const booking_history_page({super.key});

  @override
  State<booking_history_page> createState() => _booking_history_pageState();
}

class _booking_history_pageState extends State<booking_history_page> {
  List<booking_doctor> booking_doc = [];
  bool isloading = true;
  String? errormessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _show_booking_doc();
    // booking_doc.reversed;
  }

  // request retrieve for the many json in the specific data send
  Future<void> _show_booking_doc() async {
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try {
      final response = await http.get(Uri.parse(
          "http://$ip:8000/booking_doctor/spec_user_booking/$phone_number/"),
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          booking_doc = jsonResponse
              .map((data) => booking_doctor.fromJson(data))
              .toList();
          isloading = false;
        });
      } else {
        setState(() {
          errormessage = "failed to load doctor details";
          isloading = false;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      isloading = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Booking History",
            style: TextStyle(
                color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>search_booking_history()));
            }, icon: Icon(Icons.search,color: Color(0xff1f8acc),))
          ],
          // bottom: PreferredSize(
          //   preferredSize: Size.fromHeight(60),
          //   child: Padding(
          //     padding: EdgeInsets.only(
          //       left: 10.0,
          //     ),
          //     child: Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Container(
          //           width: 360,
          //           child: SearchBar(
          //             leading: Icon(Icons.search),
          //             hintText: 'Search Booking Doctor',
          //             backgroundColor: WidgetStatePropertyAll(Colors.white),
          //             // shadowColor: WidgetStatePropertyAll(Colors.grey),
          //             elevation: WidgetStatePropertyAll(6.0),
          //             shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20))),
          //             padding: WidgetStatePropertyAll(
          //                 EdgeInsets.symmetric(horizontal: 16.0)),
          //           ),
          //         )),
          //   ),
          // ),
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                itemCount: booking_doc.length,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var show_doc = booking_doc[index];
                  print("doctor name :${show_doc.doctorName}");
                  return Padding(
                    padding:  EdgeInsets.only(bottom: 10.0),
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          show_doc.doctorName ?? "No Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Specialty: ${show_doc.specialty ?? "Not Available"}"),
                            Text("Service: ${show_doc.service ?? "Not Available"}"),
                            Text("Language: ${show_doc.language ?? "Not Available"}"),
                            Text("Qualification: ${show_doc.qualification ?? "Not Available"}"),
                            Text("Location: ${show_doc.doctorLocation ?? "Not Available"}"),
                            Text("Date: ${show_doc.bookingDate ?? "Not Available"}"),
                            Text("Time: ${show_doc.bookingTime ?? "Not Available"}"),
                          ],
                        ),
                      ),
                    ),
                  );

                },
              ),
            ),
            Container(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}


class search_booking_history extends StatefulWidget {
  const search_booking_history({super.key});

  @override
  State<search_booking_history> createState() => _search_booking_historyState();
}

class _search_booking_historyState extends State<search_booking_history> {
  TextEditingController searchController =TextEditingController();
  List<booking_doctor> booking_doc = [];
  String phone_number = "";
  bool isloading = true;

  Future<void> _search_booking_historys(String query)async{
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString("phone_number")??"";
      phone_number = phone_number.replaceFirst("+", "");
    });
    try{
      String pati_phone_number = Uri.encodeQueryComponent(phone_number);
      String  encodedquery= Uri.encodeQueryComponent(query);
      final response = await http.get(Uri.parse("http://$ip:8000/booking_doctor/get_chat_history/?phone_number=$pati_phone_number&q=$encodedquery"));
      if(response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        if(jsonResponse is Map && jsonResponse.containsKey('result')){
          var resultList = jsonResponse['result'];
          if(resultList is List){
            setState(() {
              booking_doc=resultList.map((data)=>booking_doctor.fromJson(data)).toList();
              isloading = false;
            });

          }else{
            setState(() {
              booking_doc =[];
              isloading = false;
            });
          }
        }else{
          setState(() {
            booking_doc =[];
            isloading=false;
          });
        }
      }else{
        setState(() {
          booking_doc =[];
          isloading=false;
        });
      }
    }catch(e){
      print("object$e");
      setState(() {
        isloading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextField(
          controller: searchController,
          cursorColor: Color(0xff1f8acc),
          style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            focusColor: Colors.black,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color
            ),
            hintText: "Search Doctor...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (query) {
            if (query.length > 1) {
              _search_booking_historys(query);
            }
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: ListView.builder(
              itemCount: booking_doc.length,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var show_doc = booking_doc[index];
                print("doctor name :${show_doc.doctorName}");
                return Padding(
                  padding:  EdgeInsets.only(bottom: 10.0),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        show_doc.doctorName ?? "No Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Specialty: ${show_doc.specialty ?? "Not Available"}"),
                          Text("Service: ${show_doc.service ?? "Not Available"}"),
                          Text("Language: ${show_doc.language ?? "Not Available"}"),
                          Text("Qualification: ${show_doc.qualification ?? "Not Available"}"),
                          Text("Location: ${show_doc.doctorLocation ?? "Not Available"}"),
                          Text("Date: ${show_doc.bookingDate ?? "Not Available"}"),
                          Text("Time: ${show_doc.bookingTime ?? "Not Available"}"),
                        ],
                      ),
                    ),
                  ),
                );

              },
            ),
          ),
          Container(
            height: 100,
          )
        ],
      ),
    );
  }
}

