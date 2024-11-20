import 'dart:convert';
import 'package:ess_app/views/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Attendance {
  final int id;
  final String name;
  final String employeeId;
  final String attDate;
  final String shiftId;
  final String grade;
  final String shiftName;
  final String depName;
  final String desName;
  final String sectionName;
  final String shiftStartTime;
  final String shiftEndTime;
  final String attStatusName;

  Attendance({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.attDate,
    required this.shiftId,
    required this.grade,
    required this.shiftName,
    required this.depName,
    required this.desName,
    required this.sectionName,
    required this.shiftStartTime,
    required this.shiftEndTime,
    required this.attStatusName,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      name: json['name'],
      employeeId: json['employeeId'],
      attDate: json['attDate'],
      shiftId: json['shiftId'],
      grade: json['grade'],
      shiftName: json['shiftName'],
      depName: json['depName'],
      desName: json['desName'],
      sectionName: json['sectionName'],
      shiftStartTime: json['shiftStartTime'],
      shiftEndTime: json['shiftEndTime'],
      attStatusName: json['attStatusName'],
    );
  }
}

class MonthlyAttendance extends StatefulWidget {
  const MonthlyAttendance({super.key});

  @override
  State<MonthlyAttendance> createState() => _MonthlyAttendanceState();
}

class _MonthlyAttendanceState extends State<MonthlyAttendance> {
  bool isLoading = false;
  String empId = "";
  List<Attendance>? attendance;

  // Controllers for date pickers
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  // Variables to store selected dates
  DateTime? searchStartDate;
  DateTime? searchEndDate;

  void setEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('idemp');

    setState(() {
      empId = id ?? "";
    });

    if (empId.isNotEmpty) {
      fetchAttendanceList();
    }
  }

  Future<void> fetchAttendanceList() async {
    if (empId.isEmpty || searchStartDate == null || searchEndDate == null) {
      print("Employee ID or Dates are empty, cannot fetch attendance list.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.get(
        Uri.parse(
          'API URL',
        ),
      );

      if (response.statusCode == 200) {
        var responseJSON = jsonDecode(response.body) as Map<String, dynamic>;
        var data = responseJSON['data'] as List;

        // Convert JSON data to a list of Attendance objects
        List<Attendance> attendanceList = data.map((item) => Attendance.fromJson(item)).toList();

        setState(() {
          attendance = attendanceList;
          isLoading = false;
        });
      } else {
        print("Failed to fetch data: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setEmployee();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first;
        if (isStartDate) {
          searchStartDate = picked;
        } else {
          searchEndDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance List',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(
        child: SpinKitWave(
          color: Color(0xff97a6ff),
          size: 50,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Pickers
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: "Start Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController, true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: "End Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController, false),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
                    fetchAttendanceList();
                  } else {
                    print("Please select both dates");
                  }
                },
                child: Text("Fetch Attendance"),
              ),
              const SizedBox(height: 20),

              // Attendance List
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: attendance?.length ?? 0,
                itemBuilder: (context, index) {
                  final att = attendance![index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // Space between cards
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.all(20),
                              content: SizedBox(
                                width: size.width * 0.7,
                                height: size.height * 0.3,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Attendance Details",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          const Text(
                                            "Attendance Date:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${att.attDate.split('T').first}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          const Text(
                                            "Shift Name:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${att.shiftName}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),

                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          const Text(
                                            "Status:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${att.attStatusName}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          const Text(
                                            "Shift Start Time:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${att.shiftStartTime}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          const Text(
                                            "Shift End Time:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${att.shiftEndTime}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          const Text(
                                            "Section Name:",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${att.sectionName}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // ... other attendance details
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date: ${att.attDate.split('T').first}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Shift: ${att.shiftName}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Department Name: ${att.depName}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

