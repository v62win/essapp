import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendarview extends StatefulWidget {
  const Calendarview({super.key});

  @override
  State<Calendarview> createState() => _CalendarviewState();
}

class _CalendarviewState extends State<Calendarview> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Dummy data for attendance
  final Map<DateTime, String> _attendanceData = {
    DateTime(2024, 8, 10): 'Present',
    DateTime(2024, 8, 12): 'Leave',
    DateTime(2024, 8, 14): 'Half Day',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              children: [
                Text(
                  'Attendance Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,
                    height: 1.8,
                  ),
                ),

                const SizedBox(height: 20),
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 1, 1),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // Match day with attendance data
                      final attendanceStatus = _attendanceData[DateTime(day.year, day.month, day.day)];

                      if (attendanceStatus != null) {
                        Color? bgColor;
                        if (attendanceStatus == 'Present') {
                          bgColor = Colors.green;
                        } else if (attendanceStatus == 'Leave') {
                          bgColor = Colors.red;
                        } else if (attendanceStatus == 'Half Day') {
                          bgColor = Colors.orange;
                        }

                        return Container(
                          width: 35, // Smaller width
                          height: 35, // Smaller height
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            ': Present',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            ': Half Day',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            ': Leave',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
