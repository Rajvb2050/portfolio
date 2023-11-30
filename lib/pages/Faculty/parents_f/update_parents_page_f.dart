import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class UpdateParentPage extends StatefulWidget {
  final String id;
  const UpdateParentPage({Key? key, required this.id}) : super(key: key);
  @override
  UpdateParentPageState createState() => UpdateParentPageState();
}

class UpdateParentPageState extends State<UpdateParentPage> {
  final _formKey = GlobalKey<FormState>();
  CollectionReference students =
      FirebaseFirestore.instance.collection('Admin/$admin/parents');
  Future<void> updateUser(id, name, child) {
    return students
        .doc(id)
        .update({'name': name, 'child': child})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  String? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Parent"),
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
                    .collection('Admin/$admin/students')
                    .where('branch', isEqualTo: branch)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final items = snapshot.data!.docs
                      .map((doc) => doc.get('number'))
                      .toList();
                  return Form(
                      key: _formKey,
                      child:
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Admin/$admin/parents')
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 30),
                            child: ListView(
                              children: [
                                const Text(
                                  'Student',
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
                                    value: child,
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
                                        child = value;
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
                                        return 'Please select a student';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: TextFormField(
                                    readOnly: true,
                                    maxLength: 10,
                                    initialValue: number,
                                    autofocus: false,
                                    onChanged: (value) => number = value,
                                    decoration: const InputDecoration(
                                      labelText: 'Mobile Number: ',
                                      labelStyle: TextStyle(fontSize: 20.0),
                                      border: OutlineInputBorder(),
                                      errorStyle: TextStyle(fontSize: 15),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Enrollment Number';
                                      } else if (value.length != 10) {
                                        return 'Please Enter Valid Enrollment Number';
                                      }
                                      return null;
                                    },
                                  ),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          updateUser(widget.id, name, child);
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
