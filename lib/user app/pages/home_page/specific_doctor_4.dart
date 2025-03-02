import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../Backend_information/Backend_doctor_details.dart';
import '../../../main.dart';
import 'doctor_profile_3.dart';

class Specific extends StatefulWidget {
  final dynamic data;
  const Specific({super.key,required this.data});

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
    _showdoctor1();
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
            return doctor.specialty ==  "${widget.data}"
                ? Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15, bottom: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(40),
                ),

                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      scale: 5,
                      doctor.doctorImage != null
                          ? "http://$ip:8000${doctor.doctorImage}"
                          : "https://cdn-icons-png.flaticon.com/128/10701/10701484.png",
                      // Fallback image if null
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "${doctor.doctorName ?? "unknown"}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 48.0),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      heart = !heart;
                                    });
                                  },
                                  icon: Icon(
                                    heart
                                        ? FontAwesomeIcons.solidHeart
                                        : FontAwesomeIcons.heart,
                                    color: heart ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 200,
                            child: Text(
                              doctor.bio ?? "No bio",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 3, // Limit the text to 3 lines
                              overflow: TextOverflow
                                  .ellipsis, // Add "..." if the text exceeds maxLines
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>doc_profile(data: "${doctor.id}",)));
                                  }, child: Text("Book",style: TextStyle(color: Color(0xff0a8eac)),)),
                              Padding(
                                padding: EdgeInsets.only(left: 38.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  width: 60,
                                  child: Text("${doctor.regNo ?? 0}")),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
                : SizedBox(height: 0,);
          }),
    );
  }
}
