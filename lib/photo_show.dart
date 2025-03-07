// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:health_hub/main.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart';
//
// class ImageUploadPage extends StatefulWidget {
//   @override
//   _ImageUploadPageState createState() => _ImageUploadPageState();
// }
//
// class _ImageUploadPageState extends State<ImageUploadPage> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//   final String uploadUrl = 'http://$ip:8000/user_profile/user_edit/917845711277/';
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }
//
//   Future<void> _uploadImage() async {
//     if (_image == null) return;
//
//     var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
//     request.files.add(await http.MultipartFile.fromPath(
//       'user_photo',
//       _image!.path,
//       filename: basename(_image!.path),
//     ));
//
//     var response = await request.send();
//
//     if (response.statusCode == 200) {
//       print('Image uploaded successfully.');
//     } else {
//       print('Image upload failed with status: ${response.statusCode}.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Upload Image')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _image == null
//                 ? Text('No image selected.')
//                 : Image.file(_image!),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text('Select Image'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _uploadImage,
//               child: Text('Upload Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:health_hub/user%20app/pages/home_page/hoem_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'main.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  Uint8List? _webImage;
  io.File? _image;
  final ImagePicker _picker = ImagePicker();


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        // For Mobile
        setState(() {
          _image = io.File(pickedFile.path);
        });
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    final String uploadUrl = 'http://$ip:8000/user_profile/user_edit/917845711277/';
    if (kIsWeb && _webImage != null) {
      // Web upload
      var request = http.MultipartRequest('PUT', Uri.parse(uploadUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'user_photo',
        _webImage!,
        filename: 'upload.png', // Adjust the filename as needed
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        Navigator.push(context as BuildContext, MaterialPageRoute(builder: (context)=>home_page()));
        print('Image uploaded successfully.');
      } else {
        print('Image upload failed with status: ${response.statusCode}.');
      }
    } else if (!kIsWeb && _image != null) {
      // Mobile upload
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'user_photo',
        _image!.path,
        filename: basename(_image!.path),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
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
      appBar: AppBar(title: Text('Upload Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 2),
                      blurRadius: 12)
                ],
                shape: BoxShape.circle,
                image: DecorationImage(

                  image: _image != null
                      ? FileImage(_image!) // For Mobile (File)
                      : _webImage != null
                      ? MemoryImage(_webImage!) // For Web (Uint8List)
                      : AssetImage('assets/placeholder.png') as ImageProvider, // Placeholder
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ]
          // <Widget>[
          //   if (kIsWeb)
          //     _webImage == null
          //         ? Text('No image selected.')
          //         : Image.memory(_webImage!)
          //   else
          //     _image == null
          //         ? Text('No image selected.')
          //         : Image.file(_image!),
          //   SizedBox(height: 20),
          //   ElevatedButton(
          //     onPressed: _pickImage,
          //     child: Text('Select Image'),
          //   ),
          //   SizedBox(height: 20),
          //   ElevatedButton(
          //     onPressed: _uploadImage,
          //     child: Text('Upload Image'),
          //   ),
          // ],
        ),
      ),
    );
  }
}
