import 'dart:convert';
import 'package:ess_app/views/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({super.key});

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  bool isloading = false ;
  final formKey = GlobalKey<FormBuilderState>();
  List<Map<String, dynamic>> leaveTypes = [];
  var empLeaveSlabId;
  String daysDifference = "";
  var isPaid;
  var leaveTypeId;
  var leaveAppStatus;
  var empname;
  var empgrade;
  late DateTime startDate;
  late DateTime endDate;
  late DateTime singleLeaveDate;
  bool isHalfDay = false;

  @override
  void initState() {
    super.initState();
    Setemployee();

  }

  String empid = "";

  Setemployee() async {
    setState(() {
      isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? id = prefs.getString('idemp');

    setState(() {
      empid = id!;
    });

    if (empid != null) {
      fetchLeaveSlabs();// Call leavelist only after empid is set
    }else{
      print('no emp id found');
      setState(() {
        isloading = false ;
      });
    }
  }

  Future<void> fetchLeaveSlabs() async {
    try {
      final response = await http.get(
        Uri.parse('API URL'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          empLeaveSlabId = data['data'][0]['leave_Slab']['id'];
          isPaid = data['data'][0]['leave_Slab']['leave_Type']['paymentStatus'];
          leaveAppStatus = data['data'][0]['status'];
          empname = data['data'][0]['employee']['first_name'];
          empgrade = data['data'][0]['grade']['name'];

          // Extract leave types
          leaveTypes = data['data'].map<Map<String, dynamic>>((item) => {
            'id': item['leave_Slab']['leave_Type']['id'],
            'name': item['leave_Slab']['leave_Type']['leaveTypeName'],
            'leaveSlabId': item['id'],
          }).toList();
        });
        setState(() {
           isloading = false ;
        });
      } else {
        print("Failed to fetch leave slabs");
        setState(() {
          isloading = false ;
        });
      }
    } catch (e) {
      print("Error fetching leave slabs: $e");
      setState(() {
        isloading = false ;
      });
    }
  }

  Future<void> applyLeave(Map<String, dynamic> formData) async {
    setState(() {
      isloading = true;
    });
    try {
      // Ensure leaveTypeId is not null or empty
      if (leaveTypeId == null || leaveTypeId.isEmpty) {
        showCustomDialog(
          context: context,
          title: 'Error',
          content: 'Please select a leave type!',
        );
        setState(() {
          isloading = false;
        });
        return;
      }

      // Find the leave slab ID based on the selected leave type
      final selectedLeaveSlab = leaveTypes.firstWhere(
            (leaveType) => leaveType['id'].toString() == leaveTypeId,
        orElse: () {
          showCustomDialog(
            context: context,
            title: 'Error',
            content: 'Leave type not found!',
          );
          return {'leaveSlabId': null};
        },
      );

      // Check if selectedLeaveSlabId is valid
      var selectedLeaveSlabId = selectedLeaveSlab['leaveSlabId'];
      if (selectedLeaveSlabId == null) {
        return; // Exit if leave slab ID is not found
      }

      var body = {
        "Emp_Id": empid,
        "Emp_Leave_Slab_Id": selectedLeaveSlabId,
        "Leave_Type_Id": leaveTypeId,
        "Is_Paid": isPaid,
        "No_Of_Days": daysDifference,
        "Leave_App_Status": 3,
        "LeaveDate": isHalfDay
            ? singleLeaveDate.toIso8601String().split('T').first
            : startDate.toIso8601String().split('T').first,
        "ReturnDate": isHalfDay
            ? singleLeaveDate.toIso8601String().split('T').first
            : endDate.toIso8601String().split('T').first,
        "LeaveDescription": formData['leave_description'],
        "action": "CREATE"
      };

      print(body);

      final response = await http.post(
        Uri.parse('API URL'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      var responseData = jsonDecode(response.body);

      // Display response message based on response content
      if (response.statusCode == 200) {
        showCustomDialog(
          context: context,
          title: 'Success',
          content: responseData['message'] ?? 'Leave application submitted successfully!',
        );
      } else {
        showCustomDialog(
          context: context,
          title: 'Error',
          content: responseData['error'] ?? 'An unexpected error occurred.',
        );
      }
    } catch (e) {
      showCustomDialog(
        context: context,
        title: 'Error',
        content: "$e",
      );
      print("Error applying leave: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }


// Function to display custom dialog
  void showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leave Application',
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
          :SingleChildScrollView(
        child: Column(
          children: [
            FormBuilder(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  children: [
                    _buildEmployeeInfo(),
                    const SizedBox(height: 30),
                    _buildLeaveSlabDropdown(),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildDaysDifference(),
                    const SizedBox(height: 20),
                    _buildLeaveDescriptionField(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.person, color: Color(0xff97a6ff)),
              Text(": $empname", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 25, color: Colors.black) ,softWrap: true,),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.grade, color: Color(0xff97a6ff)),
              Text(": $empgrade", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveSlabDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.beach_access, color: Color(0xff97a6ff)),
            Text(
              "Emp Leave Slab",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 5),
        FormBuilderDropdown<String>(
          name: 'leave_type',
          decoration: InputDecoration(
            hintText: 'Select your leave type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: leaveTypes.map((leaveType) {
            return DropdownMenuItem<String>(
              value: leaveType['id'].toString(),
              child: Text(leaveType['name']),
            );
          }).toList(),
          onChanged: (selectedValue) {
            setState(() {
              leaveTypeId = selectedValue;

              // Check if the selected leave type name contains "Half Day"
              bool isHalfDayLeave = leaveTypes.firstWhere(
                    (leaveType) => leaveType['id'].toString() == leaveTypeId,
                orElse: () => {'name': ''},
              )['name'].contains("Half Day");

              // If it's a half day, set day difference to 0.5
              if (isHalfDayLeave) {
                  isHalfDay = true;
                daysDifference = "0.5";
              }
              else{
                isHalfDay = false;
                daysDifference = "";
              }
            });
          },
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
        ),
      ],
    );
  }





  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month, color: Color(0xff97a6ff)),
            Text("Select Leave Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 5),
        isHalfDay
            ? FormBuilderDateTimePicker(
          name: 'HalfDayDate',
          inputType: InputType.date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          format: DateFormat('dd-MM-yyyy'),
          onChanged: (val) {
            setState(() {
              singleLeaveDate = val!;
            });
          },
          decoration: InputDecoration(
            hintText: 'Select Half Day Leave Date',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
        )
            : Column(
          children: [
            FormBuilderDateTimePicker(
              name: 'startDate',
              inputType: InputType.date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              format: DateFormat('dd-MM-yyyy'),
              onChanged: (val) {
                setState(() {
                  startDate = val!;
                });
              },
              decoration: InputDecoration(
                hintText: 'Select Start Date',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            ),
            const SizedBox(height: 20),
            FormBuilderDateTimePicker(
              name: 'endDate',
              inputType: InputType.date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              format: DateFormat('dd-MM-yyyy'),
              onChanged: (val) {
                setState(() {
                  endDate = val!;
                  // Calculate the days difference here
                  daysDifference = ((endDate.difference(startDate).inDays)).toString();
                });
              },
              decoration: InputDecoration(
                hintText: 'Select Return Date',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildDaysDifference() {
    return Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xff97a6ff)),
              Text("Number of Days", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
            ],
          ),
          SizedBox(height: 5),
          ListTile(
            title: Text(daysDifference),
            tileColor: Colors.white,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ]
    );
  }


  Widget _buildLeaveDescriptionField() {
    return FormBuilderTextField(
      name: 'leave_description',
      decoration: InputDecoration(
        hintText: 'Leave Description',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 5,
      validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState?.saveAndValidate() ?? false) {
          applyLeave(formKey.currentState!.value);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.all(15),
      ),
      child: Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white)),
    );
  }
}



