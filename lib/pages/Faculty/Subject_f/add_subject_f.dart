import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({Key? key}) : super(key: key);
  @override
  AddSubjectState createState() => AddSubjectState();
}

class AddSubjectState extends State<AddSubject> {
  final _formKey = GlobalKey<FormState>();
  var name = "";
  var number = "";
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  clearText() {
    nameController.clear();
    numberController.clear();
  }

  CollectionReference subject =
      FirebaseFirestore.instance.collection('Admin/$admin/subject');
  Future<void> addUser() {
    return subject
        .doc(number)
        .set({
          'sub_name': name,
          'sub_code': number,
          'branch': branch,
        })
        .then((value) => print('student Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Subject"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
          child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  maxLength: 7,
                  autofocus: false,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(fontSize: 15),
                  ),
                  keyboardType: TextInputType.number,
                  controller: numberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Subject Code';
                    } else if (value.length != 7) {
                      return 'Please Enter Valid Subject Code';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(fontSize: 15),
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Name';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          name = nameController.text;
                          number = numberController.text;
                          Navigator.pop(context);
                          addUser();
                        });
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {clearText()},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
