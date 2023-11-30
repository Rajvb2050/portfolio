import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';

class UpdateStudentPage extends StatefulWidget {
  final String id;
  const UpdateStudentPage({Key? key, required this.id}) : super(key: key);
  @override
  UpdateStudentPageState createState() => UpdateStudentPageState();
}

class UpdateStudentPageState extends State<UpdateStudentPage> {
  final _formKey = GlobalKey<FormState>();
  String? branch1;
  CollectionReference students =
      FirebaseFirestore.instance.collection('Admin/$admin/students');
  Future<void> updateUser(id, name, branch) async {
    students
        .doc(id)
        .update(
            {'name': name, 'branch': branch, 'batch': batchyeardropdownValue})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Student"),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Back",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
            child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Admin/$admin/department')
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final items = snapshot.data!.docs
                      .map((doc) => doc.get('name'))
                      .toList();
                  return Form(
                      key: _formKey,
                      child:
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Admin/$admin/students')
                            .doc(widget.id)
                            .get(),
                        builder: (_, snapshot) {
                          if (snapshot.hasError) {
                            print('Something Went Wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var data = snapshot.data!.data();
                          var name = data!['name'];
                          var number = data['number'];
                          batchyeardropdownValue = data['batch'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 30),
                            child: ListView(
                              children: [
                                const Text(
                                  'Branch',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
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
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: branch1,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    hint: const Text('Select an item'),
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_outlined),
                                    elevation: 16,
                                    dropdownColor: Colors.grey[100],
                                    style: const TextStyle(color: Colors.black),
                                    onChanged: (value) {
                                      setState(() {
                                        branch1 = value;
                                      });
                                    },
                                    items: items.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select a branch';
                                      }
                                      return null;
                                    },
                                  ),
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
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: TextFormField(
                                    initialValue: name,
                                    autofocus: false,
                                    onChanged: (value) => name = value,
                                    decoration: const InputDecoration(
                                      labelText: 'Name: ',
                                      labelStyle: TextStyle(fontSize: 20.0),
                                      border: OutlineInputBorder(),
                                      errorStyle: TextStyle(fontSize: 15),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: TextFormField(
                                    readOnly: true,
                                    maxLength: 12,
                                    initialValue: number,
                                    autofocus: false,
                                    onChanged: (value) => number = value,
                                    decoration: const InputDecoration(
                                      labelText: 'Enrollment Number: ',
                                      labelStyle: TextStyle(fontSize: 20.0),
                                      border: OutlineInputBorder(),
                                      errorStyle: TextStyle(fontSize: 15),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Enrollment Number';
                                      } else if (value.length != 12) {
                                        return 'Please Enter Valid Enrollment Number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          updateUser(
                                            widget.id,
                                            name,
                                            branch1,
                                          );
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text(
                                        'Update',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ));
                })));
  }
}
