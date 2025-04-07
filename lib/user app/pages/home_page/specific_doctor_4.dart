import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../main.dart';
import 'doctor_profile_3.dart';

class Specific extends StatefulWidget {
  final dynamic data;
  Specific({super.key,required this.data});

  @override
  State<Specific> createState() => _SpecificState();
}

class _SpecificState extends State<Specific> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text(
          "${widget.data} Doctor",
          style:
          TextStyle(color: Color(0xff0a8eac), fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.only(
              left: 10.0,
            ),
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  width: 360,
                  child: SearchBar(
                    leading: Icon(Icons.search),
                    hintText: 'Search a Doctor',
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    // shadowColor: WidgetStatePropertyAll(Colors.grey),
                    elevation: WidgetStatePropertyAll(6.0),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                  ),
                )),
          ),
        ),
      ),
      body: Specif_doc(data : widget.data),
    );
  }
}

class Specif_doc extends StatefulWidget {
  final String data;
  const Specif_doc({super.key, required this.data});

  @override
  State<Specif_doc> createState() => _Specif_docState();
}

class _Specif_docState extends State<Specif_doc> {
  bool heart = false;
  List<doctor_details> doctor_detail = [];
  bool isLoading = true;
  String? errorMessage;
  String? Spec;

  @override
  void initState() {
    super.initState();
    Spec = widget.data;
    // _showdoctor1();
    _get_spec_doc_search(widget.data);
  }

  //  request for retrieve the all the json using get
  Future<void> _showdoctor1() async {

    final url = Uri.parse(
        "http://$ip:8000/doctor_details/doctor_addetails/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          doctor_detail = jsonResponse
              .map((data) => doctor_details.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "failed to load doctor_details";
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

  Future<void> _get_spec_doc_search(String query) async{
    if(query.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    try{
      String encodedQuery = Uri.encodeQueryComponent(query);
      final response = await http.get(Uri.parse("http://$ip:8000/doctor_details/doctor_search/?q=$encodedQuery"));
      if(response.statusCode == 200){
        var jsonResponse = jsonDecode(response.body);
        if(jsonResponse is Map && jsonResponse.containsKey('result')){
          var result = jsonResponse['result'];
          if(result is List){
            setState(() {
              doctor_detail = result.map((data)=>doctor_details.fromJson(data)).toList();
              isLoading = false;
            });
          }else {
            setState(() {
              doctor_detail = [];
              isLoading = false;
            });
          }
        }else {
          setState(() {
            doctor_detail = [];
            isLoading = false;
          });
        }
      }else {
        setState(() {
          doctor_detail = [];
          isLoading = false;
        });
      }
    }catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: doctor_detail.length,
          itemBuilder: (context, index) {
            var doctor = doctor_detail[index];
            return doctor.specialty !=  null
                ? Padding(
              padding: EdgeInsets.only(
                  left: 13.0, right: 13, bottom: 15),
              child:
              AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  horizontalOffset: 500.0,
                  child: FadeInAnimation(
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
                          // borderRadius: BorderRadius.circular(40),
                        ),
                        height: 190,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, top: 15, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  // scale: 10,
                                  doctor.doctorImage != null
                                      ? "http://$ip:8000/media/${doctor.doctorImage}"
                                      : "no data ",
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 18.0),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${doctor.doctorName ?? "unknown"}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 5.0),
                                      child: Text(
                                        doctor.specialty ??
                                            "No specility",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 5.0),
                                      child: Text(
                                        "${doctor.service ?? "No service"} years of exp",
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
                                      padding:
                                      EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                            doc_profile(
                                                              data:
                                                              "${doctor.id}",
                                                            )));
                                              },
                                              style: OutlinedButton
                                                  .styleFrom(
                                                  backgroundColor:
                                                  Colors
                                                      .blueAccent,
                                                  shadowColor:
                                                  Colors
                                                      .grey),
                                              child: Text(
                                                "Book",
                                                style: TextStyle(
                                                    color:
                                                    Colors.white),
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
              )

            )
                : SizedBox(height: 0,);
          }),
    );
  }
}
