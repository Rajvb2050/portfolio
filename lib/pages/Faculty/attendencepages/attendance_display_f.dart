import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class AttendanceDisplayPage extends StatefulWidget {
  const AttendanceDisplayPage({Key? key}) : super(key: key);
  @override
  AttendanceDisplayPageState createState() => AttendanceDisplayPageState();
}

class AttendanceDisplayPageState extends State<AttendanceDisplayPage> {
  List<Map<String, dynamic>> lectures = [];
  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final QuerySnapshot<Map<String, dynamic>> lecturesSnapshot =
        await FirebaseFirestore.instance
            .collection('Admin/$admin/attendance')
            .where('branch', isEqualTo: branch)
            .orderBy('date', descending: true)
            .get();
    setState(() {
      lectures = lecturesSnapshot.docs
          .map((doc) => doc.data())
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Attendance'),
      ),
      body: ListView.builder(
        itemCount: lectures.length,
        itemBuilder: (BuildContext context, int index) {
          final lecture = lectures[index];
          final date = lecture['date'] as String?;
          final start = lecture['start'] as String?;
          final end = lecture['end'] as String?;
          final sub = lecture['subject'] as String?;
          final attendance = lecture['attendance'];
          Map<String, dynamic>? sortedAttendance;
          if (attendance != null) {
            final sortedKeys = attendance.keys.toList()..sort();
            sortedAttendance = {
              for (var key in sortedKeys) key: attendance[key]
            };
            print(sortedAttendance);
          }
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AttendanceDetailsPage(attendance: sortedAttendance),
                ),
              );
            },
            child: Card(
              child: ListTile(
                leading: Text('$sub'),
                trailing: Text('$date, $start - $end'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AttendanceDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? attendance;
  const AttendanceDetailsPage({Key? key, required this.attendance})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Attendance Details'),
      ),
      body: attendance != null
          ? ListView.builder(
              itemCount: attendance!.length,
              itemBuilder: (BuildContext context, int index) {
                final student = attendance!.keys.elementAt(index);
                final present = attendance![student] as bool?;
                return Card(
                  child: ListTile(
                    title: Text(student),
                    textColor: Colors.white,
                    tileColor: present == true ? green : red,
                    trailing: present == true
                        ? const Icon(Icons.check)
                        : const Icon(Icons.close),
                  ),
                );
              },
            )
          : const Center(
              child: Text('No attendance data available'),
            ),
    );
  }
}
