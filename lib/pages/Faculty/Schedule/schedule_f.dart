import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:smart_parents/pages/Faculty/Schedule/addschedule.dart';
import 'package:smart_parents/pages/Faculty/Schedule/editSchedule.dart';
import 'package:smart_parents/widgest/animation.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';

String batchyear = DateFormat('yyyy').format(DateTime.now());

class ShowSchedule extends StatefulWidget {
  const ShowSchedule({super.key});
  @override
  ShowScheduleState createState() => ShowScheduleState();
}

class ShowScheduleState extends State<ShowSchedule> {
  late List<DateTime> dates;
  int _selectedIndex = 0;
  final _service = TimetableService();
  String? _selectedDay;
  @override
  void initState() {
    super.initState();
    batchyear = DateFormat('yyyy').format(DateTime.now());
    final now = DateTime.now();
    dates = List.generate(
      DateTime(now.year + 1, 0, 0).difference(DateTime(now.year, 0, 0)).inDays,
      (index) => DateTime(now.year, 1, 1).add(Duration(days: index)),
    );
    final todayIndex = dates.indexWhere(
      (date) =>
          date.day == now.day &&
          date.month == now.month &&
          date.year == now.year,
    );
    _selectedIndex = todayIndex;
    _selectedDay = DateFormat('EEEE').format(dates[_selectedIndex]);
    print(_selectedDay);
  }

  void _showNumberPicker(BuildContext context) {
    batchyeardropdownValue = batchyear;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Select a Batch'),
          content: Dropdown(
            dropdownValue: batchyeardropdownValue,
            string: batchList,
            hint: "Batch(Starting Year)",
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    batchyear = batchyeardropdownValue;
                    Navigator.of(context).pop();
                  });
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Schedule',
          style: GoogleFonts.oswald(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Column(children: [
        CarouselSlider(
          options: CarouselOptions(
            enlargeCenterPage: true,
            initialPage: _selectedIndex,
            enableInfiniteScroll: false,
            height: 145,
            viewportFraction: 1 / 5,
            onPageChanged: (index, reason) {
              setState(() {
                _selectedIndex = index;
                _selectedDay = DateFormat('EEEE').format(dates[_selectedIndex]);
                print(_selectedDay);
              });
            },
          ),
          items: dates.map((date) {
            return Builder(
              builder: (BuildContext context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: _selectedIndex == dates.indexOf(date)
                            ? Colors.white
                            : Colors.grey,
                      ),
                      child: Transform.rotate(
                        angle: -math.pi / 2,
                        child: Text(
                          DateFormat('dd MMM').format(date),
                          style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: _selectedIndex == dates.indexOf(date)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(80),
                topRight: Radius.circular(80),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
              color: Colors.white,
            ),
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    DateFormat('E, dd MMM').format(dates[_selectedIndex]),
                    style: GoogleFonts.rubik(
                        fontSize: 30,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    child: TextButton.icon(
                      label: Text(
                        'Batch',
                        style: GoogleFonts.rubik(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      icon: Container(
                        width: 60,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: kPrimaryColor,
                        ),
                        child: Text(
                          batchyear,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      onPressed: () {
                        _showNumberPicker(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder<List<TimetableEntry>>(
                  stream: _service.getTimetableStream(_selectedDay.toString()),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('No lectures added for $_selectedDay'),
                      );
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final entry = snapshot.data![index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditSchedule(
                                              doc: entry.doc,
                                              batch: batchyear,
                                              end: entry.endTime,
                                              start: entry.startTime,
                                              subject: entry.subject,
                                              type: entry.type,
                                              day: _selectedDay.toString(),
                                            )))
                              },
                              onLongPress: () async {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                          "Are you sure you want to delete this Schedule?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete"),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Admin')
                                                .doc(admin)
                                                .collection('schedule')
                                                .doc('${branch}_$batchyear')
                                                .collection('timetable')
                                                .doc(_selectedDay)
                                                .collection('entries')
                                                .doc(entry.doc)
                                                .delete()
                                                .then((value) =>
                                                    print('Schedule Deleted'))
                                                .catchError((error) => print(
                                                    'Failed to Delete Schedule: $error'));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${entry.startTime}\n${entry.endTime}',
                                    style: GoogleFonts.rubik(
                                        fontSize: 15,
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: kPrimaryLightColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${entry.subject} ${entry.type}",
                                        style: GoogleFonts.rubik(
                                            fontSize: 20,
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ]),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context, FloatingAnimation(const AddSchedule())),
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TimetableEntry {
  final String subject;
  final String startTime;
  final String endTime;
  final String type;
  final String doc;
  TimetableEntry(
      {required this.doc,
      required this.type,
      required this.subject,
      required this.startTime,
      required this.endTime});
}

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<TimetableEntry>> getTimetableStream(String day) {
    return _firestore
        .collection('Admin')
        .doc(admin)
        .collection('schedule')
        .doc('${branch}_$batchyear')
        .collection('timetable')
        .doc(day)
        .collection('entries')
        .orderBy('start24')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TimetableEntry(
            doc: doc.id,
            subject: data['subject'],
            startTime: data['startTime'],
            endTime: data['endTime'],
            type: data['type']);
      }).toList();
    });
  }

  Future<void> deleteSchedule(id, String day) async {
    await FirebaseFirestore.instance
        .collection('Admin')
        .doc(admin)
        .collection('schedule')
        .doc('${branch}_$batchyear')
        .collection('timetable')
        .doc(day)
        .collection('entries')
        .doc(id)
        .delete()
        .then((value) => print('Schedule Deleted'))
        .catchError((error) => print('Failed to Delete Schedule: $error'));
  }
}
