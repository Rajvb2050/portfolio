import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_parents/components/constants.dart';

class EditP extends StatefulWidget {
  final String id;
  const EditP({Key? key, required this.id}) : super(key: key);
  @override
  EditPState createState() => EditPState();
}

class EditPState extends State<EditP> {
  final _formKey = GlobalKey<FormState>();
  CollectionReference parents =
      FirebaseFirestore.instance.collection('Admin/$admin/parents');
  Future<void> updateUser(id, name, email, dob) {
    return parents
        .doc(id)
        .update(({
          'name': name,
          'email': email,
          'dob': dob,
        }))
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  final _dobController = TextEditingController();
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('Admin/$admin/parents')
        .doc(widget.id)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        DateTime dob = snapshot.get('dob').toDate();
        setState(() {
          _selectedDate = dob;
          _dobController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(), title: const Text('PARENTS DETAILS')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('Admin/$admin/parents')
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
              var number = data!['number'];
              var name = data['name'];
              var email = data['email'];
              return Column(children: [
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
                        readOnly: true,
                        initialValue: number,
                        autofocus: false,
                        onChanged: (value) => number = value,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        "DOB",
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
                        autofocus: false,
                        keyboardType: TextInputType.datetime,
                        style: const TextStyle(fontSize: 20),
                        controller: _dobController,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: ElevatedButton(
                          onPressed: () => {
                                if (_formKey.currentState!.validate())
                                  {
                                    updateUser(
                                        widget.id, name, email, _selectedDate),
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
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }
}
