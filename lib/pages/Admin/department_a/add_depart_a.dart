import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class AddDepartPage extends StatefulWidget {
  const AddDepartPage({Key? key}) : super(key: key);
  @override
  AddDepartPageState createState() => AddDepartPageState();
}

class AddDepartPageState extends State<AddDepartPage> {
  final _formKey = GlobalKey<FormState>();
  var name = "";
  var departmentId = "";
  @override
  void initState() {
    super.initState();
  }

  final nameController = TextEditingController();
  final departmentController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  clearText() async {
    nameController.clear();
    departmentController.clear();
  }

  CollectionReference department =
      FirebaseFirestore.instance.collection('Admin/$admin/department');
  Future<void> addUser() {
    return department
        .doc("${departmentId}_$admin")
        .set({
          'name': name,
          'departmentId': departmentId,
        })
        .then((value) => print('department Added'))
        .catchError((error) => print('Failed to Add department: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Department"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  maxLength: 2,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Department Id: ',
                    labelStyle: const TextStyle(fontSize: 20.0),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorStyle: const TextStyle(fontSize: 15),
                  ),
                  keyboardType: TextInputType.number,
                  controller: departmentController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Faculty Id';
                    } else if (value.length != 2) {
                      return 'Please Enter Valid Faculty Id';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Department Name: ',
                    labelStyle: const TextStyle(fontSize: 20.0),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorStyle: const TextStyle(fontSize: 15),
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Department Name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          name = nameController.text;
                          departmentId = departmentController.text;
                          addUser();
                          clearText();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  backgroundColor: kPrimaryLightColor,
                                  content: Text(
                                    'Department Added.',
                                    style: TextStyle(
                                        fontSize: 18.0, color: Colors.black),
                                  )));
                        });
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {clearText()},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
