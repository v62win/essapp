import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Manager extends StatefulWidget {
  const Manager({super.key});

  @override
  State<Manager> createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  List<dynamic> leaves = [];
  String empid = "";
  bool isloading = false;
  int currentPage = 1;
  final int itemsPerPage = 20;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  var managerapiresponse ;

  @override
  void initState() {
    super.initState();
    setEmployee();
  }

  Future<void> setEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('idemp');
    if (id != null) {
      setState(() {
        empid = id;
      });
      await fetchLeaves(refresh: true);
    }
  }

  Future<void> fetchLeaves({bool refresh = false}) async {
    if (empid.isEmpty) return;

    setState(() {
      isloading = true;
    });

    try {
      var response = await http.get(
        Uri.parse('API URL'),
      );

      if (response.statusCode == 200) {
        var responseJSON = jsonDecode(response.body) as List<dynamic>;

        setState(() {
            leaves = responseJSON.reversed.toList();
        });
        print(leaves);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }
  Future<void> manageLeave(Map<String, dynamic> updatedData) async {
    setState(() {
      isloading = true;
    });

    try {
      var response = await http.put(
        Uri.parse('API URL'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
        print("Leave updated successfully");
        await fetchLeaves(); // Refresh the leave list
      }else{
        print(response.body);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  void _showEditLeaveBottomSheet(BuildContext context, dynamic leave) {
    final TextEditingController commentController = TextEditingController(text: leave['comment'] ?? '');
    final TextEditingController returnDateController = TextEditingController(text: leave['returnDate']?.split('T').first ?? '');
    final TextEditingController leaveDateController = TextEditingController(text: leave['leaveDate']?.split('T').first ?? '');
    int leaveAppStatus = leave['Leave_App_Status'] ?? 3; // default to Pending
    double noOfDays = leave['no_Of_Days'] ?? 0.0; // initial days

    void calculateNoOfDays() {
      final leaveDate = DateTime.tryParse(leaveDateController.text);
      final returnDate = DateTime.tryParse(returnDateController.text);
      if (returnDate != null) {
        noOfDays = returnDate.difference(leaveDate!).inDays.toDouble();
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Manage Leave Request', style: TextStyle( fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
                  SizedBox(height: 8),
                  Text(
                    'No of Days: $noOfDays',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: commentController,
                    decoration: InputDecoration(labelText: 'Comment'),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: leaveDateController,
                    decoration: InputDecoration(labelText: 'leave Date (YYYY-MM-DD)'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        leaveDateController.text = pickedDate.toIso8601String().split('T').first;
                        calculateNoOfDays();
                        setModalState(() {}); // update the UI in StatefulBuilder
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: returnDateController,
                    decoration: InputDecoration(labelText: 'Return Date (YYYY-MM-DD)'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        returnDateController.text = pickedDate.toIso8601String().split('T').first;
                        calculateNoOfDays();
                        setModalState(() {}); // update the UI in StatefulBuilder
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: leaveAppStatus,
                    decoration: InputDecoration(labelText: 'Leave Status'),
                    items: [
                      DropdownMenuItem(value: 3, child: Text('Pending')),
                      DropdownMenuItem(value: 4, child: Text('Approved')),
                      DropdownMenuItem(value: 5, child: Text('Rejected')),
                    ],
                    onChanged: (newStatus) {
                      setModalState(() {
                        leaveAppStatus = newStatus!;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> updatedData = {
                        "id": leave['id'],
                        "Emp_Id": leave['emp']['employee_id'],
                        "Action": "UPDATE",
                        "Is_Paid": leave['isPaid'] ?? 1,
                        "LeaveDate": leaveDateController.text,
                        "ReturnDate": returnDateController.text,
                        "No_of_Days": noOfDays,
                        "Leave_Type_Id": leave['leave_Type']['id'],
                        "Emp_Leave_Slab_Id": leave['emp_Leave_Slab']['id'],
                        "Leave_App_Status": leaveAppStatus,
                        "Comment": commentController.text,
                      };

                      await manageLeave(updatedData);
                      Navigator.pop(context);
                      print(updatedData);
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }




  void _onRefresh() async {
    await fetchLeaves(); // Refresh the data
    _refreshController.refreshCompleted(); // End the refresh
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage leaves',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: isloading
          ? Center(
          child: SpinKitWave(
            color: Color(0xff97a6ff),
            size: 50,
          ))
          : SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leaves',
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
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          elevation: 0,
                          backgroundColor: Color(0xff97a6ff), // Replace with your primaryColor
                          onPressed: () {},
                          child: const Icon(Icons.beach_access, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 20),
                        if (leaves.isNotEmpty) ...[
                          Text(
                            "Total Leaves: ${leaves.length}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            "No Leaves Found or You don't have manager permissions",
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: leaves.length,
                  itemBuilder: (context, index) {
                    final leave = leaves[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
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
                                          "Leave Application Details",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Designation:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "${leave['emp']['designation']['name']}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Department :",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['emp']['department']['name']}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Applied on:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['createdAt']?.split('T').first ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Leave-type :",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['leave_Type']['leaveTypeName']}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                              softWrap: true,
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
                                              "${leave['leaveStatus']['name'] ?? 'Unknown'}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Approved by:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['approvedBy'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Description:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "${leave['comment'] ?? 'No description provided'}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        onLongPress: () => _showEditLeaveBottomSheet(context, leave),
                        /*onLongPress: (){
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: size.height * 1,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[

                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },*/
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
                                  "Leave Date: ${leave['leaveDate']?.split('T').first ?? 'N/A'}\nReturn Date: ${leave['returnDate']?.split('T').first ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No of Days: ${leave['no_Of_Days'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Name: ${leave['emp']['first_name'] ?? 'No name found'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  softWrap: true,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child:  Text(
                                    "${leave['leaveStatus']['name'] ?? 'Unknown'}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight:FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ) ,

                                )
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
      ),
    );
  }
}

