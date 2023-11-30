import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/send_notification.dart';
import 'package:smart_parents/pages/Faculty/exam_f/addexam.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';

class Exam extends StatefulWidget {
  const Exam({Key? key}) : super(key: key);
  @override
  State<Exam> createState() => _ExamState();
}

class _ExamState extends State<Exam> with NotificationMixin {
  final nameController = TextEditingController();
  CollectionReference exams =
      FirebaseFirestore.instance.collection('Admin/$admin/exams');
  Future<void> deleteUser(id) async {
    final subcollections = exams.doc(id).collection('exam').get();
    subcollections.then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    exams
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((error) => print('Failed to Delete user: $error'));
    FirebaseStorage.instance.ref().child('$admin/exams/$id.jpg').delete();
  }

  addExam(name, batch) {
    return exams
        .add({'name': name, 'batch': batch, 'branch': branch})
        .then((value) => print('student Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Admin/$admin/exams')
            .where('branch', isEqualTo: branch)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something went Wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List storedocs = [];
          snapshot.data!.docs.map((DocumentSnapshot document) {
            Map a = document.data() as Map<String, dynamic>;
            storedocs.add(a);
            a['id'] = document.id;
          }).toList();
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: "Back",
                onPressed: () => Navigator.of(context).pop(),
              ),
              title:
                  const Text("Exam Details", style: TextStyle(fontSize: 30.0)),
            ),
            body: storedocs.isNotEmpty
                ? ListView.builder(
                    itemCount: storedocs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExam(
                                docid: storedocs[index]['id'],
                                name: storedocs[index]['name'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Exam name: ${storedocs[index]['name']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                    Text(
                                      'Batch(Starting Year): ${storedocs[index]['batch']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Delete"),
                                    IconButton(
                                      highlightColor: red,
                                      onPressed: () async {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Confirm Delete"),
                                              content: const Text(
                                                  "Are you sure you want to delete this item?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("CANCEL"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("DELETE"),
                                                  onPressed: () {
                                                    try {
                                                      deleteUser(
                                                          storedocs[index]
                                                              ['id']);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Notice deleted.')),
                                                      );
                                                    } catch (e) {
                                                      print(e);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Failed to delete Notice: $e')),
                                                      );
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : Center(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "assets/images/No data.png",
                        ),
                        const Text(
                          "No data",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text(
                        'Exam',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: TextFormField(
                                autofocus: false,
                                decoration: const InputDecoration(
                                  labelText: 'Name: ',
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
                            Dropdown(
                              dropdownValue: batchyeardropdownValue,
                              string: batchList,
                              hint: "Batch(Starting Year)",
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Add"),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() async {
                                addExam(nameController.text,
                                    batchyeardropdownValue);
                                sendNotificationToAllUsers(
                                    "Exam",
                                    '',
                                    nameController.text,
                                    await FirebaseFirestore.instance
                                        .collection('Admin/$admin/parents')
                                        .where('branch', isEqualTo: branch)
                                        .where('batch',
                                            isEqualTo: batchyeardropdownValue)
                                        .get());
                                sendNotificationToAllUsers(
                                    "Exam",
                                    '',
                                    nameController.text,
                                    await FirebaseFirestore.instance
                                        .collection('Admin/$admin/students')
                                        .where('branch', isEqualTo: branch)
                                        .where('batch',
                                            isEqualTo: batchyeardropdownValue)
                                        .get());
                                Navigator.of(context).pop();
                              });
                            }
                          },
                        ),
                      ],
                    );
                  },
                )
              },
              child: const Icon(Icons.add),
            ),
          );
        });
  }

  final _formKey = GlobalKey<FormState>();
}
