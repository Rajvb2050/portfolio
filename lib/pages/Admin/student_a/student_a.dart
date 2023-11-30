import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Admin/student_a/add_student_page_a.dart';
import 'package:smart_parents/pages/Admin/student_a/update_student_page_a.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/widgest/animation.dart';

class Student extends StatefulWidget {
  const Student({Key? key}) : super(key: key);
  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
      .collection('Admin/$admin/students')
      .snapshots();
  @override
  void initState() {
    super.initState();
    login();
  }

  CollectionReference students =
      FirebaseFirestore.instance.collection('Admin/$admin/students');
  Future<void> deleteUser(id) async {
    return students
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((error) => print('Failed to Delete user: $error'));
  }

  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  Future<void> updateStatus(id, status) async {
    students
        .doc(id)
        .update({'status': status})
        .then((value) => print('Status: $status'))
        .catchError((error) => print('Failed to update status: $error'));
    users
        .doc(id)
        .update({'status': status})
        .then((value) => print('Status: $status'))
        .catchError((error) => print('Failed to update status: $error'));
  }

  TextEditingController searchController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();
  login() async {
    FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await _prefs;
    String? email = prefs.getString('email');
    String? pass = prefs.getString('pass');
    print("signout");
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: "$email", password: "$pass")
          .then(
            (value) => print("login $email"),
          );
      print("login");
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  String number = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Student Details", style: TextStyle(fontSize: 30.0)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  number = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter Enrollment Number',
                hintText: 'Enter Enrollment Number',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    number = '';
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: studentsStream,
              builder: (context, snapshot) {
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
                return Center(
                  child: storedocs.isNotEmpty
                      ? ListView.builder(
                          itemCount: storedocs.length,
                          itemBuilder: (context, index) {
                            var data = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                            if (number.isEmpty) {
                              return Card(
                                elevation: 5,
                                shadowColor: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${storedocs[index]['batch']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                '${storedocs[index]['number']}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0),
                                              ),
                                              Text(
                                                'Name: ${storedocs[index]['name']}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Switch(
                                              activeTrackColor: Colors.white,
                                              inactiveTrackColor: Colors.white,
                                              activeColor: green,
                                              inactiveThumbColor: red,
                                              value: storedocs[index]['status'],
                                              onChanged: (value) {
                                                setState(() {
                                                  updateStatus(
                                                      storedocs[index]['id'],
                                                      value);
                                                });
                                              },
                                            ),
                                            Text(
                                              storedocs[index]['status']
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: storedocs[index]
                                                          ['status']
                                                      ? green
                                                      : red),
                                            ),
                                          ],
                                        ),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Mo: ${storedocs[index]['mono']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Branch: ${storedocs[index]['branch']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Email: ${storedocs[index]['email']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateStudentPage(
                                                        id: storedocs[index]
                                                            ['id'])),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.grey[600],
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            fixedSize: const Size(200, 40),
                                            elevation: 5,
                                            textStyle: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                        child: const Text("Edit"),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            if (data['number']
                                .toString()
                                .toLowerCase()
                                .startsWith(number.toLowerCase())) {
                              return Card(
                                elevation: 5,
                                shadowColor: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${storedocs[index]['batch']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                '${storedocs[index]['number']}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0),
                                              ),
                                              Text(
                                                'Name: ${storedocs[index]['name']}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Switch(
                                              activeTrackColor: Colors.white,
                                              inactiveTrackColor: Colors.white,
                                              activeColor: green,
                                              inactiveThumbColor: red,
                                              value: storedocs[index]['status'],
                                              onChanged: (value) {
                                                setState(() {
                                                  updateStatus(
                                                      storedocs[index]['id'],
                                                      value);
                                                });
                                              },
                                            ),
                                            Text(
                                              storedocs[index]['status']
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: storedocs[index]
                                                          ['status']
                                                      ? green
                                                      : red),
                                            ),
                                          ],
                                        ),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Mo: ${storedocs[index]['mono']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Branch: ${storedocs[index]['branch']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Email: ${storedocs[index]['email']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateStudentPage(
                                                        id: storedocs[index]
                                                            ['id'])),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.grey[600],
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            fixedSize: const Size(200, 40),
                                            elevation: 5,
                                            textStyle: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                        child: const Text("Edit"),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        )
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context, FloatingAnimation(const AddStudentPage())),
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
