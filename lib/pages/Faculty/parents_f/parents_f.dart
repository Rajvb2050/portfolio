import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/parents_f/add_parents_page_f.dart';
import 'package:smart_parents/pages/Faculty/parents_f/update_parents_page_f.dart';
import 'package:smart_parents/widgest/animation.dart';

class Parent extends StatefulWidget {
  const Parent({Key? key}) : super(key: key);
  @override
  State<Parent> createState() => _ParentState();
}

class _ParentState extends State<Parent> {
  Stream<QuerySnapshot> parentsStream = FirebaseFirestore.instance
      .collection('Admin/$admin/parents')
      .where('branch', isEqualTo: branch)
      .snapshots();
  @override
  void initState() {
    super.initState();
    login();
  }

  CollectionReference parents =
      FirebaseFirestore.instance.collection('Admin/$admin/parents');
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  Future<void> deleteUser(id) {
    return parents
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((error) => print('Failed to Delete user: $error'));
  }

  void updateStatus(id, status) {
    parents
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

  final _prefs = SharedPreferences.getInstance();
  login() async {
    FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await _prefs;
    String? email = prefs.getString('faculty');
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

  TextEditingController searchController = TextEditingController();
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
        title: const Text("Parents Details", style: TextStyle(fontSize: 30.0)),
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
                labelText: 'Enter Mobile Number',
                hintText: 'Enter Mobile Number',
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
              stream: parentsStream,
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
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  '${storedocs[index]['number']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.0),
                                                ),
                                                Text(
                                                  'Name: ${storedocs[index]['name']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17.0),
                                                ),
                                                Text(
                                                  'Child: ${storedocs[index]['child']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Switch(
                                                activeTrackColor: Colors.white,
                                                inactiveTrackColor:
                                                    Colors.white,
                                                activeColor: green,
                                                inactiveThumbColor: red,
                                                value: storedocs[index]
                                                    ['status'],
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
                                                    UpdateParentPage(
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
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  '${storedocs[index]['number']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.0),
                                                ),
                                                Text(
                                                  'Name: ${storedocs[index]['name']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17.0),
                                                ),
                                                Text(
                                                  'Child: ${storedocs[index]['child']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Switch(
                                                activeTrackColor: Colors.white,
                                                inactiveTrackColor:
                                                    Colors.white,
                                                activeColor: green,
                                                inactiveThumbColor: red,
                                                value: storedocs[index]
                                                    ['status'],
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
                                                    UpdateParentPage(
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context, FloatingAnimation(const AddParentPage())),
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
