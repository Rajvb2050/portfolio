import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/imageshow.dart';

class Notice extends StatefulWidget {
  const Notice({Key? key}) : super(key: key);
  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  Stream<QuerySnapshot> noticesStream = FirebaseFirestore.instance
      .collection('Admin/$admin/Notices')
      .where('branch', isEqualTo: branch)
      .where('batch', isEqualTo: batch)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: noticesStream,
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
              title: const Text("Notice Details",
                  style: TextStyle(fontSize: 30.0)),
            ),
            body: storedocs.isNotEmpty
                ? ListView.builder(
                    itemCount: storedocs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text(
                                  '${storedocs[index]['subject']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${storedocs[index]['notice']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0),
                                    ),
                                    if (storedocs[index]['photoUrl'] !=
                                        null) ...{
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  FullScreenImageScreen(
                                                imageUrl: storedocs[index]
                                                    ['photoUrl'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          storedocs[index]['photoUrl'],
                                        ),
                                      ),
                                    }
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          elevation: 5,
                          shadowColor: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${storedocs[index]['subject']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Date : ${storedocs[index]['date']}',
                                  style: const TextStyle(fontSize: 15),
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
          );
        });
  }
}
