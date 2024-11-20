import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'faceverification.dart';
import 'faceverification2.dart';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  late String formattedDate;
  late String formattedTime;
  Timer? timer;
  bool isloading = false ;



  @override
  void initState() {
    super.initState();
    updateClock();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateClock();
    });
  }

  void updateClock() {
    setState(() {
      formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
      formattedTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }



  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<bool> verifyLocation() async {
    setState(() {
      isloading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show dialog when permission is denied
        _showPermissionDialog();
        setState(() {
          isloading = false;
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show dialog when permission is permanently denied
      _showPermissionDialog();
      setState(() {
        isloading = false;
      });
      return false;
    }


    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);


    const officeLatitude = 26.760530539818955;
    const officeLongitude = 80.92112434004589;

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude, position.longitude, officeLatitude, officeLongitude,
    );
    print(position.latitude);
    print(position.longitude);


    if (distanceInMeters > 100) {
      // If the employee is more than 100 meters away from the office, return false
      Fluttertoast.showToast(
        msg: "You are not at the office location!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      setState(() {
        isloading = false;
      });
      return false;

    }
    setState(() {
      isloading = false;
    });
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
              "This app needs location access to verify your position. Please enable location permissions in settings."),
          actions: <Widget>[
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                Geolocator.openAppSettings(); // Open the app settings
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  Future<void> checkIn() async {
    bool locationVerified = await verifyLocation();
    if (!locationVerified) return; // Stop if location is not verified

    String currentDateTime = DateTime.now().toIso8601String();
    print("Checking In at: $currentDateTime processing....");
    // Send currentDateTime to your API here
    Navigator.push(context, MaterialPageRoute(builder: (context) => FaceVerificationScreen()));
  }

  Future<void> checkOut() async {
    bool locationVerified = await verifyLocation();
    if (!locationVerified) return; // Stop if location is not verified

    String currentDateTime = DateTime.now().toIso8601String();
    print("Checking Out at: $currentDateTime processing....");
    Navigator.push(context, MaterialPageRoute(builder: (context) => faceverification2()));
    // Send currentDateTime to your API here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In/Out'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isloading
          ? Center(
          child: SpinKitWave(
            color: Color(0xff97a6ff),
            size: 50,
          ))
          :
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Analog Clock
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SizedBox(
              height: 200,
              width: 200,
              child: AnalogClock(
                hourHandColor: Colors.black,
                minuteHandColor: Colors.black,
                secondHandColor: const Color(0xff97a6ff),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Digital Clock
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Current Date
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),

          // Check In and Check Out Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.login, color: Colors.white, size: 50,), // Set the icon
                label: const Text('Check In ', style: TextStyle(color: Colors.white),), // Set the text
                onPressed: checkIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff97a6ff),
                  minimumSize: const Size(150, 200), // Big square button
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white , size: 50,), // Set the icon
                label: const Text('Check Out', style: TextStyle(color: Colors.white),), // Set the text
                onPressed: checkOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff97a6ff),
                  minimumSize: const Size(150, 200), // Big square button
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

