import 'package:flutter/material.dart';
import 'package:smart_parents/pages/Faculty/Result_f/result_f.dart';
import 'package:smart_parents/pages/Faculty/Schedule/schedule_f.dart';
import 'package:smart_parents/pages/Faculty/Show_Stu/show1.dart';
import 'package:smart_parents/pages/Faculty/Subject_f/subject.dart';
import 'package:smart_parents/pages/Faculty/attendencepages/attendance_display_f.dart';
import 'package:smart_parents/pages/Faculty/attendencepages/attendencedropdownpage2.dart';
import 'package:smart_parents/pages/Faculty/chat_parents_f.dart';
import 'package:smart_parents/pages/Faculty/chat_student_f.dart';
import 'package:smart_parents/pages/Faculty/exam_f/exam.dart';
import 'package:smart_parents/pages/Faculty/parents_f/parents_f.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        _buildCard('Manage Subjects', Icons.book, Colors.deepPurple),
        _buildCard('Manage Parents', Icons.person_add_alt_1, Colors.teal),
        _buildCard('Manage Schedule', Icons.schedule, Colors.red),
        _buildCard(
            "Add Today's Attendances", Icons.calendar_today, Colors.green),
        _buildCard('Chat with Parents', Icons.chat, Colors.blue),
        _buildCard('Chat with Student', Icons.chat, Colors.orange),
        _buildCard('Manage Exams', Icons.library_books, Colors.purple),
        _buildCard('Manage Results', Icons.bar_chart, Colors.yellow),
        _buildCard('View Attendances', Icons.event_note, Colors.indigo),
        _buildCard('View Students', Icons.people, Colors.pink),
      ],
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
            case "Add Today's Attendances":
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AttendenceDropdownpage2()),
              );
              break;
            case 'Chat with Parents':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatParent()),
              );
              break;
            case 'Chat with Student':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatStudent()),
              );
              break;
            case 'Manage Exams':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Exam()),
              );
              break;
            case 'Manage Parents':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Parent()),
              );
              break;
            case 'Manage Results':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Result()),
              );
              break;
            case 'Manage Schedule':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowSchedule()),
              );
              break;
            case 'Manage Subjects':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubjectF()),
              );
              break;
            case 'View Attendances':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AttendanceDisplayPage()),
              );
              break;
            case 'View Students':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowStu()),
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
