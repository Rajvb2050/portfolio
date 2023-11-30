import 'package:flutter/material.dart';
import 'package:smart_parents/pages/Parents/attendance_show.dart';
import 'package:smart_parents/pages/Parents/chat_parents_f.dart';
import 'package:smart_parents/pages/Parents/contact_faculty.dart';
import 'package:smart_parents/pages/Parents/exam_p/exam.dart';
import 'package:smart_parents/pages/Parents/fees.dart';
import 'package:smart_parents/pages/Parents/livelocation.dart';
import 'package:smart_parents/pages/Parents/notice_p/notice_dash.dart';
import 'package:smart_parents/pages/Parents/result_p.dart';

class ParentsHome extends StatefulWidget {
  const ParentsHome({super.key});
  @override
  State<ParentsHome> createState() => _ParentsHomeState();
}

class _ParentsHomeState extends State<ParentsHome> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        _buildCard('Chat with Faculty', Icons.chat, Colors.green),
        _buildCard('Contact Faculty', Icons.mail, Colors.blue),
        _buildCard('Get Your Child Location', Icons.location_on, Colors.orange),
        _buildCard('View Attendances', Icons.event_note, Colors.purple),
        _buildCard('View Exams', Icons.library_books, Colors.yellow),
        _buildCard('View Results', Icons.bar_chart, Colors.teal),
        _buildCard('View Fees', Icons.attach_money, Colors.red),
        _buildCard('View Notices', Icons.notifications, Colors.deepPurple),
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
            case 'Chat with Faculty':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatParent()),
              );
              break;
            case 'Contact Faculty':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactF()),
              );
              break;
            case 'Get Your Child Location':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChildLocation()),
              );
              break;
            case 'View Attendances':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AttendanceCalendarPage()),
              );
              break;
            case 'View Results':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Result()),
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
