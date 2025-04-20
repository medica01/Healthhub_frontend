
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:health_hub/user%20app/medicine_page/pages/Med_home_page/order_successfully.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:health_hub/allfun.dart';
import 'package:health_hub/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType

class add_medincine extends StatefulWidget {
  const add_medincine({super.key});

  @override
  State<add_medincine> createState() => _add_medincineState();
}

class _add_medincineState extends State<add_medincine> {
  TextEditingController product_name = TextEditingController();
  TextEditingController product_number = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController cure_diseases = TextEditingController(); // Fixed typo
  TextEditingController about_product = TextEditingController();
  TextEditingController product_type = TextEditingController();
  File? medicine_image;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        medicine_image = File(pickedFile.path);
      });
    }
  }

  void validandaddmedi(BuildContext context) {
    List<String> missingFields = [];
    if (product_name.text.isEmpty) {
      missingFields.add("Please enter the product name");
    }
    if (product_number.text.isEmpty || product_number.text.length != 6) {
      missingFields.add("Please enter a 6-digit product number");
    }
    if (quantity.text.isEmpty) {
      missingFields.add("Please enter the product quantity");
    }
    if (price.text.isEmpty|| product_number.text.length != 3) {
      missingFields.add("Please Enter the Medicine price less than 1000");
    } else {
      try {
        double.parse(price.text); // Validate price
      } catch (e) {
        missingFields.add("Price must be a valid number");
      }
    }
    if (cure_diseases.text.isEmpty) {
      missingFields.add("Please enter the cure diseases name");
    }
    if (about_product.text.isEmpty) {
      missingFields.add("Please enter the product details");
    }
    if (product_type.text.isEmpty) {
      missingFields.add("Please enter the product type");
    }
    if (medicine_image == null) {
      missingFields.add("Please upload the product image");
    }

    if (missingFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Missing Fields",
            style: TextStyle(
              color: Colors.red,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            missingFields.join("\n"),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Confirm Details",
            style: TextStyle(
              color: Colors.green,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Please ensure the product details are correct!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    add_medicine(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> add_medicine(BuildContext context) async {
    if (medicine_image == null || !medicine_image!.existsSync()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please upload a valid image."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    var uri = Uri.parse("http://$ip:8000/medicine_pur/create_medicine_details/");
    var request = http.MultipartRequest('POST', uri);

    try {
      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        "product_image",
        medicine_image!.path,
        filename: basename(medicine_image!.path),
        contentType: MediaType('image', 'jpeg'), // Adjust if needed (e.g., 'png')
      ));

      // Add form fields with proper data types
      request.fields['product_name'] = product_name.text;
      request.fields['product_number'] = product_number.text;
      request.fields['quantity'] = int.parse(quantity.text).toString();
      request.fields['price'] = double.parse(price.text).toString();
      request.fields['cure_disases'] = cure_diseases.text; // Fixed field name
      request.fields['about_product'] = about_product.text;
      request.fields['product_type'] = product_type.text;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Response Status: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => order_success()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Upload Failed"),
            content: Text("Error: $responseBody"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to upload: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Medicine page",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            form(
              "Product Name",
              350,
              1000,
              "Enter the Medicine name",
              [FilteringTextInputFormatter.singleLineFormatter],
              product_name,
            ),
            form(
              "Product Number",
              350,
              6,
              "Enter the Medicine number (6 digits)",
              [FilteringTextInputFormatter.digitsOnly],
              product_number,
            ),
            Padding(
              padding: const EdgeInsets.only( right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  form(
                    "Quantity",
                    160,
                    1000,
                    "Eg: 500ml, 10 units",
                    [FilteringTextInputFormatter.singleLineFormatter],
                    quantity,
                  ),
                  form(
                    "Price",
                    160,
                    3,
                    "Price",
                    [FilteringTextInputFormatter.digitsOnly],
                    price,
                  ),
                ],
              ),
            ),
            form(
              "Cure Diseases",
              350,
              1000,
              "Enter the cure diseases name",
              [FilteringTextInputFormatter.singleLineFormatter],
              cure_diseases,
            ),
            form(
              "Medicine Type",
              350,
              1000,
              "Eg: tablet, syrup",
              [FilteringTextInputFormatter.singleLineFormatter],
              product_type,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 19.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "About Medicine",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: 350,
                    child: TextFormField(
                      maxLines: 5,
                      maxLength: 1000,
                      keyboardType: TextInputType.text,
                      controller: about_product,
                      autofocus: false,
                      clipBehavior: Clip.hardEdge,
                      cursorColor: const Color(0xff1f8acc),
                      style: const TextStyle(
                        color: Color(0xff1f8acc),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        counterText: "",
                        focusColor: Colors.black,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        contentPadding:
                        const EdgeInsets.only(left: 20, top: 20),
                        hintText: "Enter the medicine details",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "Medicine Image",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      height: 200,
                      width: 350,
                      child: medicine_image != null
                          ? Image.file(
                        medicine_image!,
                        fit: BoxFit.scaleDown,
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.photo,
                            color: Colors.blueAccent,
                            size: 60,
                          ),
                          Text(
                            "Add the Photo",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      product_name.clear();
                      product_number.clear();
                      quantity.clear();
                      price.clear();
                      about_product.clear();
                      product_type.clear();
                      cure_diseases.clear();
                      setState(() {
                        medicine_image = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff1f8acc)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const SizedBox(
                      width: 100,
                      height: 70,
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xff1f8acc)),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => validandaddmedi(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff1f8acc),
                      side: const BorderSide(color: Color(0xff1f8acc)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const SizedBox(
                      width: 100,
                      height: 70,
                      child: Center(
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}