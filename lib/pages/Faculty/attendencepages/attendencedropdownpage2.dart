import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/attendencepages/attendence_page.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';
import 'package:intl/intl.dart';

class Department {
  final String id;
  final String name;
  Department(this.id, this.name);
}

class Subject {
  final String id;
  final String name;
  Subject(this.id, this.name);
}

class AttendenceDropdownpage2 extends StatefulWidget {
  const AttendenceDropdownpage2({Key? key}) : super(key: key);
  @override
  AttendenceDropdownpage2State createState() => AttendenceDropdownpage2State();
}

class AttendenceDropdownpage2State extends State<AttendenceDropdownpage2> {
  final DateTime _current = DateTime.now();
  DateTime date = DateTime.now();
  String _date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  TimeOfDay start = TimeOfDay.now();
  String _start = DateFormat('hh:mm a').format(DateTime.now());
  TimeOfDay end =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  String _end = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(hours: 1)));
  String? sub;
  List<Subject> _subjects = [];
  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

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

  @override
  Widget build(BuildContext context) {
    dynamic fieldTextStyle = const TextStyle(
        color: Colors.cyan, fontSize: 17, fontWeight: FontWeight.w400);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Attendence"),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Dropdown(
                  dropdownValue: batchyeardropdownValue,
                  string: batchList,
                  hint: "Batch(Starting Year)",
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    const Text(
                      "Subject",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
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
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Text(_date.toString(), style: fieldTextStyle)),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.grey[700],
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(_current.year,
                                _current.month - 1, _current.day),
                            lastDate: DateTime(
                                _current.year, _current.month, _current.day));
                        if (picked != null) {
                          setState(() {
                            _date = DateFormat('dd-MM-yyyy').format(picked);
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
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Text(
                      _start,
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
                            _start = DateFormat('hh:mm a').format(DateTime(
                                2022, 1, 1, picked.hour, picked.minute));
                            start = picked;
                            _end = DateFormat('hh:mm a').format(
                                DateTime(2022, 1, 1, start.hour, start.minute)
                                    .add(const Duration(hours: 1)));
                            end = TimeOfDay.fromDateTime(
                                DateTime(2022, 1, 1, start.hour, start.minute)
                                    .add(const Duration(hours: 1)));
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
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Text(
                      _end,
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
                            _end = DateFormat('hh:mm a').format(DateTime(
                                2022, 1, 1, picked.hour, picked.minute));
                            end = picked;
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    width: 350,
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
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                        ]),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          _date.isEmpty
                              ? Text(
                                  "${_current.toLocal()}".split(' ')[0],
                                  style: const TextStyle(fontSize: 30),
                                )
                              : Text(
                                  _date,
                                  style: const TextStyle(fontSize: 30),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(child: Text("Branch: $branch")),
                                Expanded(child: Text("Subject: $sub"))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                        "Batch(Starting Year): $batchyeardropdownValue")),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AttendencePage(
                                                      batch:
                                                          batchyeardropdownValue,
                                                      sub: sub.toString(),
                                                      date: _date,
                                                      start: _start,
                                                      end: _end)),
                                        );
                                      },
                                      child: const Text("Take Attendence")),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
