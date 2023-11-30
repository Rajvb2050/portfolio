import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:flutter/material.dart';

class Fees extends StatefulWidget {
  const Fees({Key? key}) : super(key: key);
  @override
  State<Fees> createState() => _FeesState();
}

class _FeesState extends State<Fees> {
  Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
      .collection('Admin/$admin/fees')
      .where('number', isEqualTo: child)
      .snapshots();
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
      body: StreamBuilder<QuerySnapshot>(
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
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Sem: ${storedocs[index]['sem']}',
                                      style: const TextStyle(fontSize: 13),
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
                                      style: const TextStyle(fontSize: 13),
                                    ),
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
          );
        },
      ),
    );
  }
}
