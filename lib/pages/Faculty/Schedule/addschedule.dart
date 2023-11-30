import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/Schedule/schedule_f.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';
import 'package:intl/intl.dart';

class Subject {
  final String id;
  final String name;
  Subject(this.id, this.name);
}

class AddSchedule extends StatefulWidget {
  const AddSchedule({Key? key}) : super(key: key);
  @override
  AddScheduleState createState() => AddScheduleState();
}

class AddScheduleState extends State<AddSchedule> {
  TimeOfDay start = TimeOfDay.now();
  String _start = DateFormat('hh:mm a').format(DateTime.now());
  TimeOfDay end =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  String _end = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(hours: 1)));
  String? sub;
  List<Subject> _subjects = [];
  List<String> type = ['Lecture', 'Lab'];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  void addSchedule() async {
    var fullhour = DateFormat('HH:mm')
        .format(DateTime(2022, 1, 1, start.hour, start.minute));
    FirebaseFirestore.instance
        .collection('Admin/$admin/schedule')
        .doc('${branch}_$batchyeardropdownValue')
        .get()
        .then((value) async => {
              if (value.exists)
                {
                  await FirebaseFirestore.instance
                      .collection('Admin')
                      .doc(admin)
                      .collection('schedule')
                      .doc('${branch}_$batchyeardropdownValue')
                      .collection('timetable')
                      .doc(daysdropdownValue)
                      .collection('entries')
                      .add({
                    'subject': "$sub",
                    'type': type[selectedIndex],
                    'startTime': _start,
                    'start24': fullhour,
                    'endTime': _end,
                  })
                }
              else
                {
                  await FirebaseFirestore.instance
                      .collection('Admin/$admin/schedule')
                      .doc('${branch}_$batchyeardropdownValue')
                      .set({
                    'branch': branch,
                    'batch': batchyeardropdownValue,
                  }),
                  await FirebaseFirestore.instance
                      .collection('Admin')
                      .doc(admin)
                      .collection('schedule')
                      .doc('${branch}_$batchyeardropdownValue')
                      .collection('timetable')
                      .doc(daysdropdownValue)
                      .collection('entries')
                      .add({
                    'subject': "$sub",
                    'type': type[selectedIndex],
                    'startTime': _start,
                    'start24': fullhour,
                    'endTime': _end,
                  })
                }
            });
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

  void showAlertDialogOnOkCallback(String title, String msg,
      DialogType dialogType, BuildContext context, VoidCallback onOkPress) {
    AwesomeDialog(
      context: context,
      animType: AnimType.topSlide,
      dialogType: dialogType,
      title: title,
      desc: msg,
      btnOkIcon: Icons.check_circle,
      btnOkColor: Colors.green.shade900,
      btnOkOnPress: onOkPress,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    dynamic fieldTextStyle = const TextStyle(
        color: Colors.cyan, fontSize: 17, fontWeight: FontWeight.w400);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Add Schedule"),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customRadio(type[0], 0),
                        const SizedBox(
                          width: 10,
                        ),
                        customRadio(type[1], 1),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Dropdown(
                      dropdownValue: batchyeardropdownValue,
                      string: batchList,
                      hint: "Batch(Starting Year)",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                Dropdown(
                    dropdownValue: daysdropdownValue,
                    string: days,
                    hint: "Day"),
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
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Submit Schedule?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => {
                                            addSchedule(),
                                            showAlertDialogOnOkCallback(
                                                'Success !',
                                                'Schedule Successfully Submitted.',
                                                DialogType.success,
                                                context,
                                                () => Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ShowSchedule(),
                                                        ),
                                                        (route) => false)),
                                          },
                                          child: const Text('Submit'),
                                        ),
                                      ],
                                    ),
                                  ),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(300, 40)),
                              child: const Text("Add Schedule")),
                        ),
                      ],
                    ))
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void changeIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget customRadio(String txt, int index) {
    return OutlinedButton(
      onPressed: () => changeIndex(index),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: selectedIndex == index ? Colors.cyan : Colors.grey,
          width: 2.0,
        ),
      ),
      child: Text(
        txt,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedIndex == index ? Colors.cyan : Colors.grey),
      ),
    );
  }
}
