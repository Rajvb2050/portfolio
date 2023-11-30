import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/user_main_f.dart';

class AttendencePage extends StatefulWidget {
  const AttendencePage(
      {Key? key,
      required this.batch,
      required this.sub,
      required this.start,
      required this.end,
      required this.date})
      : super(key: key);
  final String batch;
  final String sub;
  final String start;
  final String end;
  final String date;
  @override
  AttendencePageState createState() => AttendencePageState();
}

class Name {
  final String id;
  final String name;
  Name(this.id, this.name);
}

class AttendencePageState extends State<AttendencePage> {
  List<Name> studentvar = [];
  List attd = [];
  List color = [];
  List number = [];
  @override
  void initState() {
    super.initState();
    _fetchNames();
  }

  List<Map<String?, String>> attendance = [];
  void _updateAttendance() async {
    Map<String, dynamic> attendanceMap = {};
    for (int i = 0; i < studentvar.length; i++) {
      attendanceMap[number[i]] = attd[i] == 'P' ? true : false;
    }
    await FirebaseFirestore.instance
        .collection('Admin/$admin/attendance')
        .doc('${widget.date}_${widget.start}_${widget.end}')
        .set({
      'date': widget.date,
      'start': widget.start,
      'end': widget.end,
      'branch': branch,
      'batch': widget.batch,
      'subject': widget.sub,
      'attendance': attendanceMap,
    });
  }

  void _handleSubmitted() {
    _updateAttendance();
  }

  Future<void> _fetchNames() async {
    final QuerySnapshot<Map<String, dynamic>> namesSnapshot =
        await FirebaseFirestore.instance
            .collection('Admin/$admin/students')
            .where("branch", isEqualTo: branch)
            .where("batch", isEqualTo: widget.batch)
            .where('status', isEqualTo: true)
            .orderBy('number')
            .orderBy('name')
            .get();
    final List<Name> names = [];
    final List nu = [];
    final List ad = [];
    final List co = [];
    for (final DocumentSnapshot<Map<String, dynamic>> namesSnapshot
        in namesSnapshot.docs) {
      final Name name = Name(namesSnapshot.id, namesSnapshot.data()!['name']);
      names.add(name);
      nu.add(namesSnapshot.id);
      ad.add('P');
      co.add(const Color(0xff00CE2D));
    }
    setState(() {
      studentvar = names;
      number = nu;
      attd = ad;
      color = co;
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
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Attendence"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView.builder(
                itemCount: studentvar.length,
                itemBuilder: (BuildContext context, int index) =>
                    buildAttendenceCard(context, index)),
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Submit Attendence?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => {
                      _handleSubmitted(),
                      showAlertDialogOnOkCallback(
                          'Success !',
                          'Attendance Successfully Submitted.',
                          DialogType.success,
                          context,
                          () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const UserMainF()),
                              )),
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            style: ElevatedButton.styleFrom(fixedSize: const Size(300, 40)),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  buildAttendenceCard(BuildContext context, int index) {
    var index2 = index + 1;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (attd[index] == 'P') {
            changeState(attd, index, 'A');
            changeColor(attd, index);
          } else {
            changeState(attd, index, 'P');
            changeColor(attd, index);
          }
        });
      },
      child: Card(
        color: color[index],
        elevation: 2,
        shadowColor: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Text(
                index2.toString(),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                width: 25,
              ),
              Text(
                "${studentvar[index].id}-${studentvar[index].name}",
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeState(List isSelectedList, int value, String i) {
    isSelectedList[value] = i;
  }

  void changeColor(List isSelectedList, int index) {
    if (isSelectedList[index] == 'P') {
      color[index] = const Color(0xff00CE2D);
      print("changed to : $isSelectedList");
    } else {
      color[index] = const Color(0xffff0800);
      print("changed to : $isSelectedList");
    }
  }
}
