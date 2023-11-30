import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({Key? key}) : super(key: key);
  @override
  AttendanceCalendarPageState createState() => AttendanceCalendarPageState();
}

class AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  final _prefs = SharedPreferences.getInstance();
  String? id;
  void getUserName() async {
    final SharedPreferences prefs = await _prefs;
    id = prefs.getString('id');
  }

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  var day = DateFormat('dd-MM-yyyy').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Attendance Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: kPrimaryLightColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayTextStyle: TextStyle(color: Colors.black),
            ),
            firstDay: DateTime(2021, 1, 1),
            lastDay: DateTime.now(),
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                day = DateFormat('dd-MM-yyyy').format(selectedDay);
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Admin/$admin/attendance')
                  .where('date', isEqualTo: day)
                  .where('batch', isEqualTo: batch)
                  .where('branch', isEqualTo: branch)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final data = documents[index].data();
                      final attendanceData =
                          data['attendance'] as Map<String, dynamic>?;
                      final lecturePresent = attendanceData?[id] ?? false;
                      return Card(
                        color: lecturePresent ? green : red,
                        elevation: 5,
                        shadowColor: Colors.grey[200],
                        child: ListTile(
                          textColor: Colors.white,
                          title: Text('${data['subject']} '),
                          subtitle: Text('${data['start']} - ${data['end']}'),
                          trailing: Text(lecturePresent ? 'Present' : 'Absent'),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data != null && snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("There are no Attendance! 😟",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: 'poppins')));
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
