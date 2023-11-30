import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class StudentF extends StatefulWidget {
  final String batch;
  const StudentF({Key? key, required this.batch}) : super(key: key);
  @override
  StudentFState createState() => StudentFState();
}

class StudentFState extends State<StudentF> {
  CollectionReference students =
      FirebaseFirestore.instance.collection('Admin/$admin/students');
  String number = '';
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Back",
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:
              const Text("Student Details", style: TextStyle(fontSize: 30.0)),
        ),
        body: Column(children: [
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
                  stream: FirebaseFirestore.instance
                      .collection('Admin/$admin/students')
                      .where("batch", isEqualTo: widget.batch)
                      .where("branch", isEqualTo: branch)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  storedocs[index]['status']
                                                      ? 'Active'
                                                      : 'Inactive',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Branch: ${storedocs[index]['branch']}',
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Email: ${storedocs[index]['email']}',
                                                  style: const TextStyle(
                                                      fontSize: 13),
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
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  storedocs[index]['status']
                                                      ? 'Active'
                                                      : 'Inactive',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Branch: ${storedocs[index]['branch']}',
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Email: ${storedocs[index]['email']}',
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                    );
                  }))
        ]));
  }
}
