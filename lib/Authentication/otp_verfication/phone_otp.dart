import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_hub/main.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:http/http.dart' as http;

import '../../choose_user_or_doc.dart';
import '../../user app/pages/home.dart';



class Phone_Enter extends StatefulWidget {
  const Phone_Enter({super.key});

  @override
  State<Phone_Enter> createState() => _Phone_EnterState();
}

class _Phone_EnterState extends State<Phone_Enter> {
  bool _login = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checklogin();
  }
  Future<void> _checklogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool login = prefs.getBool('login') ?? false;
    setState(() {
      _login = login ?? false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return _login ?HomePage():choose_use_doc();
  }
}

class PhoneEntryPage extends StatefulWidget {
  @override
  _PhoneEntryPageState createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends State<PhoneEntryPage> {
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
            phoneNumber=phoneNumber?.replaceFirst("+91", "");
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

  // both android and web google login
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        // Web-specific sign-in method
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

        await saveUserData(userCredential.user);

        return userCredential.user;


      } else {
        // Android-specific sign-in method
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Save user data to Firestore
        await saveUserData(userCredential.user);

        return userCredential.user;
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Future<void> signOut() async {
  //   await _auth.signOut();
  //   if (!kIsWeb) {
  //     await GoogleSignIn().signOut(); // Only needed for mobile
  //   }
  // }



  // google login for web
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //     googleProvider.setCustomParameters({'prompt': 'select_account'});
  //
  //     // Web-specific sign-in method
  //     UserCredential userCredential =
  //     await FirebaseAuth.instance.signInWithPopup(googleProvider);
  //
  //     User? user = userCredential.user;
  //
  //     if (user != null) {
  //       print("User Email: ${user.email}");
  //     }
  //
  //     return user;
  //   } catch (e) {
  //     print("Google Sign-In Error: $e");
  //     return null;
  //   }
  // }


  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;
  //
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );
  //
  //     final userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     // Save user data to Firestore
  //     await saveUserData(userCredential.user);
  //
  //     return userCredential.user;
  //   } catch (e) {
  //     print('Exception -> $e');
  //     return null;
  //   }
  // }

  Future<void> saveUserData(User? user) async {
    if (user != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setBool("login", true);
      await pref.setString("uid", user.uid ?? "");
      await pref.setString("name", user.displayName ?? "");
      await pref.setString("email", user.email ?? "");
      await pref.setString("photourl", user.photoURL ?? "");

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastLogin': DateTime.now(),
      };

      await firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
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
                        print("$phoneNumber");
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
                                builder: (context) => OtpPage(
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
                        User? user = await signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        }
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

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String data;

  OtpPage({required this.verificationId, required this.data});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _chech_phone_number() async {
    String check_number = widget.data;
    try {
      final response = await http.post(
          Uri.parse(
            "http://$ip:8000/user_profile/check_phone_number/",
          ),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            'phone_number': check_number}
          ));
      if (response.statusCode == 200) {
        SharedPreferences perf = await SharedPreferences.getInstance();
        await perf.setBool('login', true);
        await perf.setString('phone_number', check_number);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("user already exist")));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else if (response.statusCode == 404){
        await _user_profile();
      }
    } catch (e) {
      // Handle exceptions such as network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to server: $e")),
      );
    }
  }

  Future<void> _user_profile() async {
    String save_phone_number = widget.data;

    try {
      final response = await http.post(
        Uri.parse('http://$ip:8000/user_profile/user_create/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'phone_number': save_phone_number,
        }),
      );
      if (response.statusCode == 201) {
        SharedPreferences perf = await SharedPreferences.getInstance();
        await perf.setBool('login', true);
        await perf.setString('phone_number', save_phone_number);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("phone number add successfully")));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        print('add phone number failed:${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("add phone number failed: ${response.body}")));
      }
    } catch (e) {}
  }

  Future<void> _verifyOtp() async {
    String otp = _otpController.text.trim();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
       await _chech_phone_number();
      // Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
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
            await _verifyOtp();  // Correct call to the method

          },
          child: const Text('Verify OTP'),
        ),

          ],
        ),
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// class PhoneAuthPage extends StatefulWidget {
//   @override
//   _PhoneAuthPageState createState() => _PhoneAuthPageState();
// }
//
// class _PhoneAuthPageState extends State<PhoneAuthPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//
//   String? verificationId;
//   bool otpSent = false;
//
//   Future<void> sendOTP() async {
//     String phoneNumber = "+91${phoneController.text.trim()}"; // Change country code if needed
//
//     await _auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       timeout: const Duration(seconds: 60),
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await _auth.signInWithCredential(credential);
//         Fluttertoast.showToast(msg: "Auto Verification Success!");
//         Navigator.pushReplacementNamed(context, '/home');
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         Fluttertoast.showToast(msg: "Verification Failed: ${e.message}");
//       },
//       codeSent: (String verId, int? resendToken) {
//         setState(() {
//           verificationId = verId;
//           otpSent = true;
//         });
//         Fluttertoast.showToast(msg: "OTP Sent!");
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         verificationId = verId;
//       },
//     );
//   }
//
//   Future<void> verifyOTP() async {
//     if (verificationId == null) {
//       Fluttertoast.showToast(msg: "Invalid verification ID.");
//       return;
//     }
//
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId!,
//         smsCode: otpController.text.trim(),
//       );
//
//       await _auth.signInWithCredential(credential);
//       Fluttertoast.showToast(msg: "OTP Verified Successfully!");
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Invalid OTP, try again.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Phone OTP Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!otpSent) ...[
//               TextField(
//                 controller: phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(labelText: "Enter Phone Number"),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: sendOTP,
//                 child: Text("Send OTP"),
//               ),
//             ] else ...[
//               PinCodeTextField(
//                 length: 6,
//                 controller: otpController,
//                 appContext: context,
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {},
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: verifyOTP,
//                 child: Text("Verify OTP"),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
