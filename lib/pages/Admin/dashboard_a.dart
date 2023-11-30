import 'package:flutter/material.dart';
import 'package:smart_parents/pages/Admin/department_a/depart_a.dart';
import 'package:smart_parents/pages/Admin/faculty_a/faculty_a.dart';
import 'package:smart_parents/pages/Admin/fees.dart';
import 'package:smart_parents/pages/Admin/notice_a/notice_a.dart';
import 'package:smart_parents/pages/Admin/student_a/student_a.dart';

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
        _buildCard('Manage Departments', Icons.account_balance, Colors.orange),
        _buildCard('Manage Faculty', Icons.person, Colors.blue),
        _buildCard('Manage Students', Icons.people, Colors.green),
        _buildCard('Manage Notice', Icons.notifications, Colors.purple),
        _buildCard('Manage Fees', Icons.monetization_on, Colors.teal),
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
            case 'Manage Students':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Student()),
              );
              break;
            case 'Manage Faculty':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Faculty()),
              );
              break;
            case 'Manage Departments':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Department()),
              );
              break;
            case 'Manage Notice':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notice()),
              );
              break;
            case 'Manage Fees':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Fees()),
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
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
