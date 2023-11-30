import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_parents/components/constants.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});
  @override
  TimetablePageState createState() => TimetablePageState();
}

class TimetablePageState extends State<TimetablePage> {
  final _service = TimetableService();
  final _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  String _selectedDay = 'Monday';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Timetable'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Select day:'),
          DropdownButton<String>(
            value: _selectedDay,
            onChanged: (value) {
              setState(() {
                _selectedDay = value!;
              });
            },
            items: _days.map((day) {
              return DropdownMenuItem<String>(
                value: day,
                child: Text(day),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<TimetableEntry>>(
              stream: _service.getTimetableStream(_selectedDay),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No lectures added for $_selectedDay'),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final entry = snapshot.data![index];
                    return ListTile(
                      title: Text(entry.subject),
                      subtitle: Text('${entry.startTime} - ${entry.endTime}'),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add lecture:'),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(hintText: 'Subject'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _startController,
                  decoration: const InputDecoration(hintText: 'Start time'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a start time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _endController,
                  decoration: const InputDecoration(hintText: 'End time'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an end time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final subject = _subjectController.text;
                      final start = _startController.text;
                      final end = _endController.text;
                      final timetableEntry = TimetableEntry(
                          subject: subject, startTime: start, endTime: end);
                      await _service.addTimetableEntry(
                          _selectedDay, timetableEntry);
                      _subjectController.clear();
                      _startController.clear();
                      _endController.clear();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimetableEntry {
  final String subject;
  final String startTime;
  final String endTime;
  TimetableEntry(
      {required this.subject, required this.startTime, required this.endTime});
}

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<TimetableEntry>> getTimetableStream(String day) {
    return _firestore
        .collection('Admin')
        .doc(admin)
        .collection('timetable')
        .doc(day)
        .collection('entries')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TimetableEntry(
            subject: data['subject'],
            startTime: data['startTime'],
            endTime: data['endTime']);
      }).toList();
    });
  }

  Future<void> addTimetableEntry(String day, TimetableEntry entry) async {
    await _firestore
        .collection('Admin')
        .doc(admin)
        .collection('timetable')
        .doc(day)
        .collection('entries')
        .add({
      'subject': entry.subject,
      'startTime': entry.startTime,
      'endTime': entry.endTime,
    });
  }
}
