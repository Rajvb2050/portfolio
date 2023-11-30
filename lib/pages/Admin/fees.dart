import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/pages/Admin/fees_add.dart';
import 'package:smart_parents/widgest/animation.dart';

class Fees extends StatefulWidget {
  const Fees({Key? key}) : super(key: key);
  @override
  State<Fees> createState() => _FeesState();
}

class _FeesState extends State<Fees> {
  Stream<QuerySnapshot> studentsStream =
      FirebaseFirestore.instance.collection('Admin/$admin/fees').snapshots();
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
        title: const Text("Fees Details", style: TextStyle(fontSize: 30.0)),
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
                                        Expanded(
                                          child: Text(
                                            '${storedocs[index]['number']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Fees: ${storedocs[index]['amount']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Name: ${storedocs[index]['name']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Sem: ${storedocs[index]['sem']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'DateTime: ${storedocs[index]['date']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                        Expanded(
                                          child: Text(
                                            '${storedocs[index]['number']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Fees: ${storedocs[index]['amount']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Name: ${storedocs[index]['name']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Sem: ${storedocs[index]['sem']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'DateTime: ${storedocs[index]['date']}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Center(
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    "assets/images/No data.png",
                                  ),
                                  const Text(
                                    "No data",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
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
          Navigator.push(context, FloatingAnimation(const FeesAdd())),
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
