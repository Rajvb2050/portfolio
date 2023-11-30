import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_parents/components/constants.dart';

class AddExamTimeTable extends StatefulWidget {
  const AddExamTimeTable({Key? key, required this.docid, required this.name})
      : super(key: key);
  final String docid;
  final String name;
  @override
  State<AddExamTimeTable> createState() => _AddExamTimeTableState();
}

class Subject {
  final String id;
  final String name;
  Subject(this.id, this.name);
}

class _AddExamTimeTableState extends State<AddExamTimeTable> {
  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  addExam(subject, date, start, end) {
    CollectionReference exam = FirebaseFirestore.instance
        .collection('Admin/$admin/exams/${widget.docid}/exam');
    return exam
        .add({
          'subject': subject,
          'date': date,
          'starttime': start,
          'endtime': end
        })
        .then((value) => print('student Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  String? sub;
  List<Subject> _subjects = [];
  Future<void> _fetchSubjects() async {
    final QuerySnapshot<Map<String, dynamic>> subjectSnapshot =
        await FirebaseFirestore.instance
            .collection('Admin/$admin/subject')
            .get();
    final List<Subject> subjects = [];
    for (final DocumentSnapshot<Map<String, dynamic>> subjectSnapshot
        in subjectSnapshot.docs) {
      final Subject subject =
          Subject(subjectSnapshot.id, subjectSnapshot.data()!['sub_name']);
      subjects.add(subject);
    }
    setState(() {
      _subjects = subjects;
      sub = _subjects[0].name;
    });
  }

  final DateTime current = DateTime.now();
  String date0 = DateFormat('dd-MM-yyyy').format(DateTime.now());
  DateTime date = DateTime.now();
  TimeOfDay start = TimeOfDay.now();
  String start0 = DateFormat('hh:mm a').format(DateTime.now());
  TimeOfDay end =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  String end0 = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(hours: 1)));
  dynamic fieldTextStyle = const TextStyle(
      color: Colors.cyan, fontSize: 17, fontWeight: FontWeight.w400);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.name, style: const TextStyle(fontSize: 30.0)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                "Subject",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 0.80),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      ),
                    ]),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: sub,
                  icon: const Icon(Icons.keyboard_arrow_down_outlined),
                  elevation: 16,
                  dropdownColor: Colors.grey[100],
                  style: const TextStyle(color: Colors.black),
                  underline: Container(height: 0, color: Colors.black),
                  onChanged: (value) {
                    setState(() {
                      sub = value;
                    });
                  },
                  items: _subjects.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.name,
                      child: Text(item.name),
                    );
                  }).toList(),
                ),
              ),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.calendar_today,
                  ),
                  Expanded(
                      child: Text(date0.toString(), style: fieldTextStyle)),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey[700],
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(
                              current.year, current.month - 1, current.day),
                          lastDate: DateTime(
                              current.year, current.month + 2, current.day));
                      if (picked != null) {
                        setState(() {
                          date0 = DateFormat('dd-MM-yyyy').format(picked);
                          date = picked;
                        });
                      }
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.access_time,
                  ),
                  Expanded(
                      child: Text(
                    start0,
                    style: fieldTextStyle,
                  )),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey[700],
                    ),
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                          context: context, initialTime: start);
                      if (picked != null) {
                        setState(() {
                          start0 = DateFormat('hh:mm a').format(
                              DateTime(2022, 1, 1, picked.hour, picked.minute));
                          start = picked;
                          end0 = DateFormat('hh:mm a').format(
                              DateTime(2022, 1, 1, start.hour, start.minute)
                                  .add(const Duration(hours: 1)));
                          end = TimeOfDay.fromDateTime(
                              DateTime(2022, 1, 1, start.hour, start.minute)
                                  .add(const Duration(hours: 1)));
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.access_time,
                  ),
                  Expanded(
                      child: Text(
                    end0,
                    style: fieldTextStyle,
                  )),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey[700],
                    ),
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                          context: context, initialTime: end);
                      if (picked != null) {
                        setState(() {
                          end0 = DateFormat('hh:mm a').format(
                              DateTime(2022, 1, 1, picked.hour, picked.minute));
                          end = picked;
                        });
                      }
                    },
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      addExam(sub, date0, start0, end0);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Add Exam TimeTable")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
