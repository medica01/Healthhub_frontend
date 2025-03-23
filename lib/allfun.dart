import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget text(String text, Color color, double size, FontWeight weight) {
  return Container(
    child: Text(
      text,
      textScaler: TextScaler.linear(1),
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    ),
  );
}
Widget textfield2(Color c1, Color c2, Color c3, double int, Offset offset,
    BorderRadius br, EdgeInsets ei, String text) {
  return Container(
    decoration: BoxDecoration(borderRadius: br, color: c1, boxShadow: [
      BoxShadow(color: c2, blurRadius: int, offset: offset, spreadRadius: 2)
    ]),
    child: TextFormField(
      style: TextStyle(color: c3),
      cursorColor: c3,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        // focusedBorder: InputBorder.none,
        hintText: text,
        hintStyle: TextStyle(
          color: c3,
        ),
        contentPadding: ei,
        border: OutlineInputBorder(
            borderRadius: br,
            borderSide: BorderSide.merge(
              BorderSide(color: Colors.red),
              BorderSide.none,
            )),
      ),
    ),
  );
}
Widget textfielld2(
    Color c1,
    Color c2,
    Color c3,
    BorderRadius br,
    EdgeInsets ei,
    double hor,
    double ver,
    String text,
     // String retun,
    TextEditingController txt,
    ) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: hor, vertical: ver),
    decoration: BoxDecoration(
      borderRadius: br,
      color: c1,
    ),
    child: TextFormField(
      controller: txt,
      style: TextStyle(color: c3),
      // controller: txt,
      cursorColor: c3,
      // keyboardType: inputtype,
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return retun;
      //   }
      //   return null;
      // },
      decoration: InputDecoration(

        errorStyle: TextStyle(height: 0),
        hintText: text,
        hintStyle: TextStyle(color: c2),
        contentPadding: ei,
        border:
        OutlineInputBorder(borderRadius: br, borderSide: BorderSide.none),
      ),

    ),
  );
}

// appbar functions
AppBar customAppBar(String title, {bool centertitle = false}) {
  return AppBar(
    title: Text(title, style: TextStyle(color: Color(0xff1f8acc))),
    backgroundColor: Colors.white,
    centerTitle: centertitle,
  );
}

// doctor details collect in this text form field
Widget doc_form_field (String text,TextEditingController tec,TextInputType type) {
  return Padding(
    padding:  EdgeInsets.only(top: 8.0,bottom: 14,left: 13,right: 13),
    child: TextFormField(
      keyboardType: type,
      controller: tec,
      autofocus: true,
      clipBehavior: Clip.hardEdge,
      cursorColor: Color(0xff1f8acc),
      style: TextStyle(color: Color(0xff1f8acc),fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          focusColor: Colors.black,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color
          ),
          contentPadding: EdgeInsets.only(left: 20),
          hintText: text,
          hintStyle: TextStyle(color: Color(0xff1f8acc)),
          border: OutlineInputBorder(
            borderSide: BorderSide.merge(
              BorderSide(color: Colors.black),
              BorderSide.none,
            ),
          )),
    ),
  );
}


Widget form(
    String head,
    double a,
    int maxlng,
    String hint,
    TextInputType numstr,
    TextEditingController control,
    ) {
  return Padding(
    padding: EdgeInsets.only(bottom: 19.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.only(bottom: 10.0),
          child: Text(head, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: a,
          child: TextFormField(
            maxLength: maxlng,
            keyboardType: numstr,
            controller: control,
            autofocus: true,
            clipBehavior: Clip.hardEdge,
            cursorColor: Color(0xff1f8acc),
            style: TextStyle(
              color: Color(0xff1f8acc),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: "",
              focusColor: Colors.black,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                ), // Focused border color
              ),
              contentPadding: EdgeInsets.only(left: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide.merge(
                  BorderSide(color: Colors.black),
                  BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

