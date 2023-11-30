import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditA extends StatefulWidget {
  final String id;
  const EditA({Key? key, required this.id}) : super(key: key);
  @override
  EditAState createState() => EditAState();
}

class EditAState extends State<EditA> {
  final _formKey = GlobalKey<FormState>();
  CollectionReference students = FirebaseFirestore.instance.collection('Admin');
  Future<void> updateUser(id, name, email, mono) {
    return students
        .doc(id)
        .update(({'name': name, 'email': email, 'mono': mono}))
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(), title: const Text('ADMIN DETAILS')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('Admin')
                .doc(widget.id)
                .get(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                print('Something Went Wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var data = snapshot.data!.data();
              var email = data!['email'];
              var name = data['name'];
              var mono = data['mono'];
              return Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'EDIT',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextFormField(
                          initialValue: name,
                          autofocus: false,
                          onChanged: (value) => name = value,
                          style: const TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Email",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: email,
                          autofocus: false,
                          onChanged: (value) => email = value,
                          style: const TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Mobile Number",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: TextFormField(
                          initialValue: mono,
                          autofocus: false,
                          onChanged: (value) => mono = value,
                          style: const TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () => {
                              if (_formKey.currentState!.validate())
                                {
                                  updateUser(widget.id, name, email, mono),
                                  Navigator.pop(context)
                                }
                            },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
