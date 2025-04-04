
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_hub/Authentication/doc_otp_verfication/doctor_details_collect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:http/http.dart' as http;
import '../../Doctor app/doctor_homepage.dart';
import '../../choose_user_or_doc.dart';
import '../../main.dart';

class doc_otp extends StatefulWidget {
  const doc_otp({super.key});

  @override
  State<doc_otp> createState() => _doc_otpState();
}

class _doc_otpState extends State<doc_otp> {
  bool _doc_login = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _check_doc_login();
  }

  Future<void> _check_doc_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool login = prefs.getBool('doc_login') ?? false;
    setState(() {
      _doc_login = login ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _doc_login ? docHomePage() : choose_use_doc();
  }
}

class doc_otp_verfiy extends StatefulWidget {
  const doc_otp_verfiy({super.key});

  @override
  State<doc_otp_verfiy> createState() => _doc_otp_verfiyState();
}

class _doc_otp_verfiyState extends State<doc_otp_verfiy> {
  final TextEditingController _phoneController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? phoneNumber;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSimInfo();
    // Lock orientation to portrait mode for this page
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Reset orientation to allow rotation when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  Future<void> fetchSimInfo() async {
    // Request phone permission
    if (await Permission.phone.request().isGranted) {
      try {
        // Retrieve SIM information
        final simCardInfoPlugin = SimCardInfo();
        List<SimInfo>? simInfo = await simCardInfoPlugin.getSimInfo();

        // Check if SIM information is available
        if (simInfo != null && simInfo.isNotEmpty) {
          setState(() {
            phoneNumber =
                simInfo[0].number; // Get the phone number of the first SIM card
            phoneNumber = phoneNumber?.replaceFirst("+91", "");
            _phoneController.text = phoneNumber!;
            isLoading = false;
          });
        } else {
          setState(() {
            phoneNumber = 'No SIM information available.';
            _phoneController.text = phoneNumber!;
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          phoneNumber = 'Failed to get SIM information: $e';
          _phoneController.text = phoneNumber!;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        phoneNumber = 'Phone permission denied.';
        _phoneController.text = phoneNumber!;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: Container(
          height: screen.height * 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    child: Image.network(
                      "https://img.freepik.com/free-vector/hospital-logo-design-vector-medical-cross_53876-136743.jpg?uid=R162018176&ga=GA1.1.249085122.1736660184&semt=ais_hybrid",
                    ),
                  ),
                  Text(
                    "All is Well",
                    style: TextStyle(
                      color: Color(0xff1f8acc),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text(
                      "Sign in/ Sign up",
                      style: TextStyle(
                        color: Color(0xff1f8acc),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 18.0, right: 18, top: 18),
                    child: TextFormField(
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length!=10) {
                          return "no phone number";
                        }
                        return null;
                      },
                      style: TextStyle(color: Color(0xff1f8acc)),
                      cursorColor: Color(0xff1f8acc),
                      maxLength: 10,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _phoneController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        focusColor: Color(0xff46c8bb),
                        contentPadding: EdgeInsets.only(left: 120),
                        counterText: "",
                        hintText: 'Enter Phone Number',
                        hintStyle: TextStyle(color: Color(0xff1f8acc)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.merge(
                              BorderSide(color: Color(0xff1f8acc)),
                              BorderSide.none,
                            )),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xff46c8bb)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40))),
                    onPressed: () async {
                      if (_form.currentState!.validate()) {
                        String phoneNumber =
                            '+91${_phoneController.text.trim()}';
                        await _auth.verifyPhoneNumber(
                          phoneNumber: phoneNumber,
                          verificationCompleted:
                              (PhoneAuthCredential credential) async {
                            // Auto-retrieve not applicable here
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                Text('Verification failed: ${e.message}'),
                              ),
                            );
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocOtpPage(
                                  verificationId: verificationId,
                                  data: '$phoneNumber',
                                ),
                              ),
                            );
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      }
                    },
                    child: SizedBox(
                        height: 50,
                        width: 275,
                        child: Center(
                            child: Text(
                                style: TextStyle(
                                    fontSize: 20, color: Color(0xff1f8acc)),
                                'Continue'))),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => doc_details_col()));
                      },
                      child: Container(
                        height: 51,
                        width: 330,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50)),
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              FontAwesomeIcons.google,
                              color: Colors.white,
                            ),
                            Text(
                              "Continue with Google",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DocOtpPage extends StatefulWidget {
  final String verificationId;
  final String data;

  const DocOtpPage(
      {super.key, required this.verificationId, required this.data});

  @override
  State<DocOtpPage> createState() => _DocOtpPageState();
}

class _DocOtpPageState extends State<DocOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyOtp() async {
    String otp = _otpController.text.trim();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      await _doc_chech_phone_number();
      // Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  Future<void> _doc_chech_phone_number() async {
    String check_number = widget.data;
    try {
      final response = await http.post(
          Uri.parse(
            "http://$ip:8000/doctor_details/doc_check_phone/",
          ),
          headers: {"Content-Type": "application/json"},
          body: json.encode({'doctor_phone_no': check_number}));
      if (response.statusCode == 200) {
        SharedPreferences perf = await SharedPreferences.getInstance();
        await perf.setBool('doc_login', true);
        await perf.setString('doctor_phone_no', check_number);
        await perf.setString('phone_number', check_number);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("user already exist")));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => docHomePage()));
      } else if (response.statusCode == 404) {
        await _doc_profile();
      }
    } catch (e) {
      // Handle exceptions such as network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to server: $e")),
      );
    }
  }

  Future<void> _doc_profile() async {
    String save_phone_number = widget.data;
    SharedPreferences perf = await SharedPreferences.getInstance();
    // await perf.setBool('doc_login', true);
    await perf.setString('doctor_phone_no', save_phone_number);
    await perf.setString('phone_number', save_phone_number);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("phone number add successfully")));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => doc_details_col()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to your phone",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PinCodeTextField(
              controller: _otpController,
              appContext: context,
              length: 6,
              // Number of OTP fields
              onChanged: (value) {},
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                selectedColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _verifyOtp(); // Correct call to the method
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}