import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/main.dart';
import 'package:health_hub/user%20app/Other_feature/search_fav_doc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Backend_information/get_fav_doc_backend.dart';
import '../pages/home_page/doctor_profile_3.dart';

class show_fav_doc extends StatefulWidget {

  const show_fav_doc({super.key});

  @override
  State<show_fav_doc> createState() => _show_fav_docState();
}

class _show_fav_docState extends State<show_fav_doc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        centerTitle: true,
        title: Text(
          "Favorite doctor",
          style: TextStyle(
              color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>search_fav_doc()));
          }, icon: Icon(Icons.search))
        ],
      ),
      body: show_doc(),
    );
  }
}

class show_doc extends StatefulWidget {
  const show_doc({super.key});

  @override
  State<show_doc> createState() => _show_docState();
}

class _show_docState extends State<show_doc> {
  List<get_fav_doc> get_fav_doctor = [];
  bool like = false;
  bool isloading = false;
  String errormessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _show_favorite_doc();
  }

  Future<void> _delete_fav(int doctor_id) async{
    String phone_number = "";
    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      phone_number = perf.getString('phone_number') ?? "917845711277";
      phone_number = phone_number.replaceFirst('+', '');
    });
    try{
      final response = await http.delete(Uri.parse("http://$ip:8000/booking_doctor/delete_fav_doc/$phone_number/$doctor_id/"));
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
      final response = await http.get(Uri.parse(
          "http://$ip:8000/booking_doctor/get_fav_doc/$phone_number/"),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          get_fav_doctor =
              jsonResponse.map((data) => get_fav_doc.fromJson(data)).toList();
          print("${response.body}");
          isloading=true;
        });
      }
      else {
        setState(() {
          errormessage = "failed to load favorite doctor details";
          isloading=true;
        });
      }
    } catch (e) {
      errormessage = e.toString();
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: Text("Alert Message",style: TextStyle(
          color: Colors.red,fontWeight: FontWeight.bold,fontSize: 25
        ),),
        content: Text("$errormessage",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("Ok"))
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading
      ?( get_fav_doctor.isEmpty
        ?Center(
      child: Text(
        "No Favorite Doctor",
        style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
    ):ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
              itemCount: get_fav_doctor.length,
              itemBuilder: (context, index) {
                var fav_doc = get_fav_doctor[index];
                return fav_doc.id!= null
                  ?AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      horizontalOffset: 500.0,
                      child: FadeInAnimation(
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.hardEdge,
                          shadowColor: Colors.grey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(40),
                            ),
                            height: 190,
                            child: Padding(
                              padding:
                              EdgeInsets.only(left: 10.0, top: 15, bottom: 15),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                        // scale: 10,
                                        fav_doc.doctorImage != null
                                            ? "http://$ip:8000${fav_doc.doctorImage}"
                                            : "https://www.pinterest.com/pin/tik-tok-profile-picture--88523948917046149/",
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 18.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${fav_doc.doctorName}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(left: 28.0),
                                                child: IconButton(
                                                  onPressed: () {
                                                    _delete_fav(fav_doc.doctor as int);
                                                    setState(() {
                                                      get_fav_doctor.removeAt(index); // Remove the card from the local list
                                                    });
                                                  },
                                                  icon: Icon(
                                                    fav_doc.like ==true ? FontAwesomeIcons.solidHeart
                                                        : FontAwesomeIcons.heart,
                                                    color:fav_doc.like==true? Colors.red : Colors.grey,

                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 5.0),
                                            child: Text(
                                              "${fav_doc.specialty}",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 5.0),
                                            child: Text(
                                              "${fav_doc.service} years of exp",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: EdgeInsets.only(bottom: 5.0),
                                          //   child: Text(
                                          //     doctor.language ?? "english",
                                          //     style: TextStyle(
                                          //       fontSize: 14,
                                          //     ),
                                          //   ),
                                          // ),
                                          // Padding(
                                          //   padding: EdgeInsets.only(bottom: 5.0),
                                          //   child: Text(
                                          //     doctor.doctorLocation ??
                                          //         "No specility",
                                          //     style: TextStyle(
                                          //       fontSize: 14,
                                          //     ),
                                          //   ),
                                          // ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  doc_profile(
                                                                    data:
                                                                    "${fav_doc.doctor}",
                                                                  )));
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                        backgroundColor:
                                                        Colors.blueAccent,
                                                        shadowColor: Colors.grey),
                                                    child: Text(
                                                      "Book",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                    : SizedBox.shrink();
              }),
        ),
        Container(
          height: 100,
        )
      ],
    )):Center(child: CircularProgressIndicator(),);
  }
}
