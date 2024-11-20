import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Zoomimage extends StatefulWidget {
  const Zoomimage({super.key});

  @override
  State<Zoomimage> createState() => _ZoomimageState();
}

class _ZoomimageState extends State<Zoomimage> {
  String? image;

   Future<void>getimage()async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     setState(() {
       image = prefs.getString('profileImagePath');
     });

   }

  @override
  void initState(){
    super.initState();
    getimage();

  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile Pic'),
    ),
      body: Container(
        color: Colors.black,
        height: size.height * 1,
        width: size.width,
        child: InteractiveViewer(
          child: image != null
              ? Image.file(File(image!), fit: BoxFit.fitWidth)
              : Image.asset('assets/images/placeholder.png'),

        ),




      )

    );
  }
}
