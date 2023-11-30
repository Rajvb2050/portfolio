import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Parents/contact_faculty.dart';
import 'package:smart_parents/pages/Student/Schedule/schedule_u.dart';
import 'package:smart_parents/pages/Student/attendance.dart';
import 'package:smart_parents/pages/Student/chat_student.dart';
import 'package:smart_parents/pages/Student/fees.dart';
import 'package:smart_parents/pages/Student/notice_s/notice_dash.dart';
import 'package:smart_parents/pages/Parents/exam_p/exam.dart';
import '../Parents/result_p.dart';

Timer? timer;

class DashboardS extends StatefulWidget {
  const DashboardS({Key? key}) : super(key: key);
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardS> {
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getLocationData();
    });
  }

  final _prefs = SharedPreferences.getInstance();
  getLocationData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final SharedPreferences prefs = await _prefs;
      var id = prefs.getString('id');
      var role = prefs.getString('role');
      if (role == 'student') {
        Location location = Location();
        await location.requestPermission();
        LocationData locationData = await location.getLocation();
        final fireStore = FirebaseFirestore.instance;
        fireStore
            .collection('Admin/$admin/students/$id/location')
            .doc(id)
            .get()
            .then((value) => {
                  if (value.exists)
                    {
                      fireStore
                          .collection('Admin/$admin/students/$id/location')
                          .doc(id)
                          .update({
                        'latitude': locationData.latitude,
                        'longitude': locationData.longitude,
                        'timestamp': DateTime.now(),
                      })
                    }
                  else
                    {
                      fireStore
                          .collection('Admin/$admin/students/$id/location')
                          .doc(id)
                          .set({
                        'latitude': locationData.latitude,
                        'longitude': locationData.longitude,
                        'timestamp': DateTime.now(),
                      })
                    }
                });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: [
            _buildCard('Chat with Faculty', Icons.chat, Colors.green),
            _buildCard('Contact Faculty', Icons.mail, Colors.blue),
            _buildCard('View Attendance', Icons.event_note, Colors.orange),
            _buildCard('View Exams', Icons.library_books, Colors.purple),
            _buildCard('View Fees', Icons.attach_money, Colors.teal),
            _buildCard('View Notices', Icons.notifications, Colors.yellow),
            _buildCard('View Results', Icons.bar_chart, Colors.red),
            _buildCard('View Schedule', Icons.schedule, Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData iconData, Color color) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Chat with Faculty':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatStudent()),
              );
              break;
            case 'Contact Faculty':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactF()),
              );
              break;
            case 'View Attendance':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AttendanceCalendarPage()),
              );
              break;
            case 'View Exams':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Exam()),
              );
              break;
            case 'View Fees':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Fees()),
              );
              break;
            case 'View Notices':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notice()),
              );
              break;
            case 'View Results':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Result()),
              );
              break;
            case 'View Schedule':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowSchedule()),
              );
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: color,
              size: 64.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
