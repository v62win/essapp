import 'dart:convert';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:ess_app/database/databasehelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({Key? key}) : super(key: key);

  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isSaving = false;
  String empid = "";
  String fname = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
    _showStableHandToast();
    Setemployee();
  }

  Setemployee() async {

    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? id = prefs.getString('idemp');

    setState(() {
      empid = id!;
      fname = name!;
    });


  }
  void _showStableHandToast() {
    Fluttertoast.showToast(
      msg: "Keep your hand stable or place ur device in table",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras.last, ResolutionPreset.high);
      await _cameraController.initialize();
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error initializing camera: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,  // Enable face contours
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _captureAndRegisterFace() async {
    if (!_cameraController.value.isInitialized) {
      Fluttertoast.showToast(
        msg: "Camera not initialized.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      return;
    }

    try {
      final imageFile = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces[0];
        await _saveFaceData(face, empid);
       /* _showContourDialog(face);*/
        Fluttertoast.showToast(
          msg: "Face registered successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "No face detected or not inside circle.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error during face registration: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _saveFaceData(Face face, String empid) async {
    // Save face contour data in SharedPreferences
    final contourData = {
      'faceContours': {
        for (FaceContourType type in FaceContourType.values)
          type.toString(): face.contours[type]?.points
              .map((point) => {'x': point.x, 'y': point.y})
              .toList(),
      },
    };

    print("Saving Face Data for $empid: $contourData"); // Debugging the saved data
    await DatabaseHelper().insertContourData(empid, jsonEncode(contourData));
  }
  void _showContourDialog(Face face) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contour Data"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (FaceContourType type in FaceContourType.values)
                  if (face.contours[type]?.points != null)
                    Text("$type: ${face.contours[type]!.points.length} points"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double circleRadius = size.width * 0.45;

    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Face Registration')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi), // Flip horizontally
              child: CameraPreview(_cameraController),
            ),
          ),
          Positioned(
            top: size.height * 0.4 - circleRadius,
            left: size.width / 2 - circleRadius,
            child: Container(
              width: circleRadius * 2,
              height: circleRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xff97a6ff), width: 4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _isSaving
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _captureAndRegisterFace,
                child: Text("Register Face"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
















