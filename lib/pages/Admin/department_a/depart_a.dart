import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/internetcheck.dart';
import 'package:smart_parents/pages/Admin/department_a/add_depart_a.dart';
import 'package:smart_parents/widgest/animation.dart';

class Department extends StatefulWidget {
  const Department({Key? key}) : super(key: key);
  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  @override
  void initState() {
    super.initState();
    InternetPopup().initialize(context: context);
  }

  Stream<QuerySnapshot> departmentStream = FirebaseFirestore.instance
      .collection('Admin/$admin/department')
      .snapshots();
  CollectionReference department =
      FirebaseFirestore.instance.collection('Admin/$admin/department');
  Future<void> deleteUser(id) {
    return department
        .doc(id)
        .delete()
        .then((value) => print('department Deleted'))
        .catchError((error) => print('Failed to Delete department: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: departmentStream,
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
              title: const Text("Department Details",
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
                                          '${storedocs[index]['departmentId']}',
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
                                      const Text("Delete"),
                                      IconButton(
                                        highlightColor: red,
                                        onPressed: () async {
                                          try {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Confirm Delete"),
                                                  content: const Text(
                                                      "Are you sure you want to delete this item?"),
                                                  actions: [
                                                    TextButton(
                                                      child:
                                                          const Text("CANCEL"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child:
                                                          const Text("DELETE"),
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
                                                                    'Department deleted.')),
                                                          );
                                                        } catch (e) {
                                                          print(e);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Failed to delete Department: $e')),
                                                          );
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } catch (e) {
                                            print(e);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to delete Department: $e')),
                                            );
                                          }
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
                Navigator.push(
                    context, FloatingAnimation(const AddDepartPage())),
              },
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}
