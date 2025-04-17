import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health_hub/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

import '../../Doctor app/doctor_homepage.dart';
import '../../Doctor app/pages/Doc_profile_page/doc_profile_page.dart';
import '../../Notification_services.dart';
import '../../allfun.dart';
import 'doctor_details_collect_3.dart';

class doc_bio_photo extends StatefulWidget {
  const doc_bio_photo({super.key});

  @override
  State<doc_bio_photo> createState() => _doc_bio_photoState();
}

class _doc_bio_photoState extends State<doc_bio_photo> {
  String doc_phone_no = "";
  bool isloading = false;
  String? errormessge = "";
  Uint8List? webImage;
  io.File? img;
  final ImagePicker _picker = ImagePicker();
  String doc_first_name = "";
  String doc_last_name = "";
  String doc_age = "";
  String doc_email = "";
  String doc_language = "";
  String doc_location = "";
  String doc_gender = "";
  String specilty ="";
  String service="";
  String qualification="";
  String bio="";
  String reg_on="";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    doc_data_load();
  }

  Future<void> doc_data_load() async{

    SharedPreferences perf = await SharedPreferences.getInstance();
    setState(() {
      doc_phone_no = perf.getString("doctor_phone_no") ?? "";
      doc_phone_no = doc_phone_no.replaceFirst("+", "");
      doc_first_name = perf.getString("doc_first_name") ?? "";
      doc_last_name = perf.getString("doc_last_name") ?? "";
      doc_age = perf.getString("doc_age") ?? "";
      doc_email = perf.getString("doc_email") ?? "";
      doc_language = perf.getString("doc_language") ?? "";
      doc_location = perf.getString("doc_location") ?? "";
      doc_gender = perf.getString("doc_gender") ?? "";
      specilty= perf.getString("speciality") ?? "";
      service= perf.getString("service") ?? "";
      qualification= perf.getString("qualification") ?? "";
      bio= perf.getString("bio") ?? "";
      reg_on= perf.getString("reg_on") ?? "";
      print("$doc_gender");
      print("$qualification");
    });
  }

  Future<void> _pickImage() async {
    final pickedfile = await _picker.pickImage(source: ImageSource.gallery);
    // final pickedd = await _picker.pickImage(source: ImageSource.camera);
    if (pickedfile != null) {
      if (kIsWeb) {
        final bytes = await pickedfile.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        setState(() {
          img = io.File(pickedfile.path);

        });
      }
    }
  }

  Future<void> _updatedocphoto(BuildContext context) async {

    final String upload =
        'http://$ip:8000/doctor_details/doctor_addetails/';
    if (kIsWeb && webImage != null) {
      // Web upload
      var request = http.MultipartRequest('POST', Uri.parse(upload));
      request.files.add(http.MultipartFile.fromBytes(
        'doctor_image',
        webImage!,
        filename: 'upload.png', // Adjust the filename as needed
      ));
      // "doctor_name": "${doc_first_name}${doc_last_name}",
    // "doctor_phone_no": doc_phone_no,
    // "doctor_email": doc_email,
    // "age": doc_age,
    // "gender": doc_gender,
    // "language": doc_language,
    // "doctor_location": doc_location,
    // "specialty": specialty.text,
    // "service": service.text,
    // "qualification": qualification.text,
    // "bio": bio.text,
    // "reg_no": reg_on.text

      request.fields['doctor_phone_no']= "$doc_phone_no";
      request.fields['doctor_name']= "$doc_first_name $doc_last_name";
      request.fields['doctor_email']= "$doc_email";
      request.fields['age']= "$doc_age";
      request.fields['gender']= "$doc_gender";
      request.fields['language']= "$doc_language";
      request.fields['doctor_location']= "$doc_location";
      request.fields['specialty']= "$specilty";
      request.fields['service']= "$service";
      request.fields['qualification']= "$qualification";
      request.fields['bio']= "$bio";
      request.fields['reg_no']= "$reg_on";

      var response = await request.send();

      if (response.statusCode == 201) {
        SharedPreferences perf = await SharedPreferences.getInstance();
        await perf.setBool('doc_login', true);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>docHomePage()), (route)=>false);
        print('Image uploaded successfully.');
        print("$webImage");
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else if (!kIsWeb && img != null) {
      // Mobile upload
      var request = http.MultipartRequest('POST', Uri.parse(upload));
      request.files.add(await http.MultipartFile.fromPath(
        'doctor_image',
        img!.path,
        filename: basename(img!.path),
      ));

      request.fields['doctor_phone_no']= "$doc_phone_no";
      request.fields['doctor_name']= "$doc_first_name $doc_last_name";
      request.fields['doctor_email']= "$doc_email";
      request.fields['age']= "$doc_age";
      request.fields['gender']= "$doc_gender";
      request.fields['language']= "$doc_language";
      request.fields['doctor_location']= "$doc_location";
      request.fields['specialty']= "$specilty";
      request.fields['service']= "$service";
      request.fields['qualification']= "$qualification";
      request.fields['bio']= "$bio";
      request.fields['reg_no']= "$reg_on";

      var response = await request.send();

      if (response.statusCode == 201) {
        SharedPreferences perf = await SharedPreferences.getInstance();
        await perf.setBool('doc_login', true);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>docHomePage()), (route)=>false);
        NotificationService().showNotification(id: 0, title: "Health hub", body: "Hi Dr.$doc_first_name $doc_last_name, Welcome to Health Hub\nAll Is Well");
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else {
      print('No image to upload.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Choose your profile photo",
          style: TextStyle(color: Color(0xff1f8acc)),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("hello! $doc_first_name $doc_last_name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          Center(
            child: Stack(
              children: [
                Container(
                  // width: scc.width * 1,
                  // color: Colors.red,
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20, top: 10, bottom: 20),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Colors.grey,
                          //       offset: Offset(0, 2),
                          //       blurRadius: 12)
                          // ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: img != null
                                ? FileImage(img!) // For Mobile (File)
                                : webImage != null
                                ? MemoryImage(webImage!) // For Web (Uint8List)
                                : NetworkImage('https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png') as ImageProvider, // Placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                ),
                Positioned(
                  right: 13,
                  bottom: 20,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Color(0xff1f8acc), shape: BoxShape.circle),
                    child: IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 200,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                ),
                onPressed: (){
                  if(webImage !=null  || img !=null) {
                    _updatedocphoto(context);
                  }else{
                    showDialog(context: context, builder: (context)=>AlertDialog(
                      title: Text("Error",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 25),),
                      content: Text("Must must set the photo",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                      actions: [
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                          _pickImage();
                        }, child: Text("Ok"))
                      ],
                    ));
                  }
                },
                child: const Center(
                  child:  Text("Set as Profile photo",style: TextStyle(
                      color: Color(0xff1f8acc)
                  ),),
                )),
          )
        ],
      ),
    );
  }
}