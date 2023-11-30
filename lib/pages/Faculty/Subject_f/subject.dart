import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/Subject_f/add_subject_f.dart';
import 'package:smart_parents/widgest/animation.dart';

class SubjectF extends StatefulWidget {
  const SubjectF({Key? key}) : super(key: key);
  @override
  State<SubjectF> createState() => _SubjectFState();
}

class _SubjectFState extends State<SubjectF> {
  Stream<QuerySnapshot> subjectStream = FirebaseFirestore.instance
      .collection('Admin/$admin/subject')
      .where('branch', isEqualTo: branch)
      .snapshots();
  @override
  void initState() {
    super.initState();
  }

  CollectionReference subject =
      FirebaseFirestore.instance.collection('Admin/$admin/subject');
  Future<void> deleteUser(id) async {
    return subject
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((error) => print('Failed to Delete user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: subjectStream,
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
              title: const Text("Subject Details",
                  style: TextStyle(fontSize: 30.0)),
            ),
            body: storedocs.isNotEmpty
                ? ListView.builder(
                    itemCount: storedocs.length,
                    itemBuilder: (context, index) {
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
                                  '${index + 1}',
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        '${storedocs[index]['sub_code']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                      Text(
                                        'Name: ${storedocs[index]['sub_name']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.0),
                                      ),
                                      Text(
                                        'Branch: ${storedocs[index]['branch']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.0),
                                      ),
                                    ],
                                  ),
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
                              ]),
                            ],
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
                Navigator.push(context, FloatingAnimation(const AddSubject())),
              },
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}
