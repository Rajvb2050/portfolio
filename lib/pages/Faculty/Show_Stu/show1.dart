import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/Show_Stu/student_f.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';

class ShowStu extends StatefulWidget {
  const ShowStu({Key? key}) : super(key: key);
  @override
  ShowStuState createState() => ShowStuState();
}

class ShowStuState extends State<ShowStu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Student Details"),
      ),
      body: Center(
        child: ListView(physics: const BouncingScrollPhysics(), children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              const SizedBox(
                height: 30,
              ),
              Dropdown(
                dropdownValue: batchyeardropdownValue,
                string: batchList,
                hint: "Batch(Starting Year)",
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
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StudentF(batch: batchyeardropdownValue)),
                            );
                          },
                          child: const Text("Show Student")),
                    ),
                  ],
                ),
              ),
            ]),
          )
        ]),
      ),
    );
  }
}
