import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ess_app/database/databasehelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({Key? key}) : super(key: key);

  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  Map<String, dynamic>? _storedContourData;
  bool _isVerified = false;
  String empid = "";
  String fname = "";
  var deviceid ;
  bool _faceDetected = false;
  Offset? _faceCenter;

  @override
  void initState() {
    super.initState();
     Setemployee();
    _initializeCamera();
    _initializeFaceDetector();
    getDeviceId();
    _showStableHandToast();
  }
  void _showStableHandToast() {
    Fluttertoast.showToast(
      msg: "Keep your hand stable or place ur device in table ",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Setemployee() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? id = prefs.getString('idemp');

    setState(() {
      empid = id!;
      fname = name!;
    });

    // Load stored contour data after setting empid
    _loadStoredContourData(empid);
  }



  Future<void> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Device ID: ${androidInfo.id}');
      setState(() {
        deviceid = androidInfo.id;
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Device ID: ${iosInfo.identifierForVendor}');
    }
  }

  Sendlog() async {

    String currentDate = DateTime.now().toString().split(' ')[0]; // Current date in yyyy-mm-dd format
    String currentTime = TimeOfDay.now().format(context); // Current time in hh:mm format

    var body = {
      "EmpId": empid,
      "SrNo": deviceid,
      "EmpFName": fname,
      "AccessDate": currentDate,
      "AccessTime": currentTime,
    };

    var response = await http.post(
      Uri.parse('API URL'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Log successfully sent: $responseBody')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send log. Status code: ${response.statusCode}')),
      );
    }
  }


  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras.last, ResolutionPreset.high);
      await _cameraController.initialize();
      setState(() {});
      _startImageProcessing();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initializing camera: $e")),
      );
    }
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true, // Enable face contours
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _loadStoredContourData(String empid) async {
    final contourList = await DatabaseHelper().getContourData(empid);
    if (contourList.isNotEmpty) {
      setState(() {
        _storedContourData = jsonDecode(contourList[0]['contourData']);
      });
      print("Stored Face Data for $empid: $_storedContourData"); // Debugging
    } else {
      print("No stored face data found for empid $empid."); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No stored face data found for empid $empid. Please register your face.")),
      );
    }
  }


  Future<void> _captureAndVerify() async {
    if (!_cameraController.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera not initialized.")),
      );
      return;
    }

    try {
      final imageFile = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);


      setState(() {
        _faceDetected = faces.isNotEmpty;
        if (_faceDetected) {
          _faceCenter = faces[0].boundingBox.center; // Update face center
        } else {
          _faceCenter = null; // Reset face center
        }
      });


      if (_faceDetected) {
        final face = faces[0];
        final previewSize = _cameraController.value.previewSize!;
        final screenSize = MediaQuery.of(context).size;

        // Calculate the scale between the camera preview and the screen size
        final scaleX = screenSize.width / previewSize.height;
        final scaleY = screenSize.height / previewSize.width;

        // Convert face center to screen coordinates
        final faceCenterX = _faceCenter!.dx * scaleX;
        final faceCenterY = _faceCenter!.dy * scaleY;

        // Get the size and center of the circle
        double circleRadius = screenSize.width * 0.45;
        double circleCenterX = screenSize.width / 2;
        double circleCenterY = screenSize.height * 0.4;

        // Calculate the distance between the face center and the circle center
        double dx = faceCenterX - circleCenterX;
        double dy = faceCenterY - circleCenterY;
        double distance = math.sqrt(dx * dx + dy * dy);


        if (distance <= circleRadius){
          Map<String, dynamic> detectedContourData = _extractContourData(face);

          print("Detected Face Contour Data: $detectedContourData"); // Debug line

          // Compare contours and handle result
          bool result = _compareContoursWithPoseCorrection(detectedContourData, face);
          _showVerificationResult(result);

        }else {
          // Face is outside the circle
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please align your face inside the circle.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No face detected or not inside circle.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during face verification: $e")),
      );
    }
  }

  // Extract face contour data from the detected face
  Map<String, dynamic> _extractContourData(Face face) {
    Map<String, dynamic> contourData = {};
    for (FaceContourType type in FaceContourType.values) {
      final points = face.contours[type]?.points;
      if (points != null) {
        contourData[type.toString()] = points.map((p) => {'x': p.x, 'y': p.y}).toList();
      }
    }
    return contourData;
  }

  bool _compareContoursWithPoseCorrection(Map<String, dynamic> detectedContours, Face face) {
    if (_storedContourData == null) return false;

    for (FaceContourType type in FaceContourType.values) {
      final detectedPoints = detectedContours[type.toString()];
      final storedPoints = _storedContourData!['faceContours'][type.toString()];

      if (detectedPoints == null || storedPoints == null) continue;

      // Check if the contours are similar
      if (!_areContoursSimilarWithPose(detectedPoints, storedPoints, face)) {
        print("Contour mismatch at $type");
        return false; // Return false if any contour doesn't match
      }
    }
    return true; // All contours match
  }

  bool _areContoursSimilarWithPose(List<dynamic> detected, List<dynamic> stored, Face face) {
    if (detected.length != stored.length) return false;

    for (int i = 0; i < detected.length; i++) {
      // Apply pose correction (this is a simple placeholder)
      int correctedX = detected[i]['x']; // Adjust as needed
      int correctedY = detected[i]['y']; // Adjust as needed

      num dx = (correctedX - stored[i]['x']).abs();
      num dy = (correctedY - stored[i]['y']).abs();

      // Debugging contour points
      print("Comparing points: detected (x:${correctedX}, y:${correctedY}), stored (x:${stored[i]['x']}, y:${stored[i]['y']})");

      // Check if the difference is within an acceptable tolerance
      if (dx > 40 || dy > 40) { // Adjust tolerance as needed
        print("Point mismatch at index $i: dx=$dx, dy=$dy");
        return false; // Return false if there's a mismatch
      }
    }
    return true; // All points match
  }

  String currentDateTime = DateTime.now().toIso8601String();

  void _startImageProcessing() {
    Future.delayed(const Duration(milliseconds: 3000));
    if (_cameraController.value.isInitialized) {
      _captureAndVerify();
      // Schedule the next processing after a small delay
      Future.delayed(const Duration(milliseconds: 5000), _startImageProcessing);
    }
  }

  void _showVerificationResult(bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Verification Result"),
          content: Text(isSuccess ? "Checking In at: $currentDateTime" : "Face verification failed."),
          actions: <Widget>[
            TextButton(
              child: Text("okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Only send log if verification is successful
    if (isSuccess) {
      Sendlog();
    }
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
      appBar: AppBar(title: Text('Face Verification')),
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
                border: Border.all(
                  color: _faceDetected
                      ? Colors.green
                      : _faceCenter != null &&
                      _faceCenter!.dx >= (size.width / 2 - circleRadius) &&
                      _faceCenter!.dx <= (size.width / 2 + circleRadius) &&
                      _faceCenter!.dy >= (size.height * 0.4 - circleRadius) &&
                      _faceCenter!.dy <= (size.height * 0.4 + circleRadius)
                      ? Colors.green
                      : Color(0xff97a6ff), // Change color based on detection
                  width: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}















