import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({Key? key}) : super(key: key);
  @override
  AddStudentPageState createState() => AddStudentPageState();
}

class AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  var name = "";
  var number = "";
  var password = "";
  String? branch1;
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  clearText() {
    nameController.clear();
    numberController.clear();
    passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    login();
  }

  CollectionReference students =
      FirebaseFirestore.instance.collection('Admin/$admin/students');
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  registration() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: "$number@sps.com", password: password)
          .then((value) {});
      students
          .doc(number)
          .set({
            'name': name,
            'number': number,
            'password': password,
            'branch': branch1,
            'status': true,
            'batch': batchyeardropdownValue
          })
          .then((value) => print('student Added'))
          .catchError((error) => print('Failed to Add user: $error'));
      users
          .doc(number)
          .set(
              {'id': number, 'role': 'student', 'status': true, 'admin': admin})
          .then((value) => print('student Added'))
          .catchError((error) => print('Failed to Add user: $error'));
      clearText();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            "Student Added.",
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
      );
      login();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'weak-password') {
        print("Password Provided is too Weak");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              "Password Provided is too Weak",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        print("Student Already exists");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              "Student Already exists",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      }
    }
  }

  final _prefs = SharedPreferences.getInstance();
  login() async {
    FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await _prefs;
    String? email = prefs.getString('email');
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

  bool showPassword = false;
  void _togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Student"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('Admin/$admin/department')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final items =
                  snapshot.data!.docs.map((doc) => doc.get('name')).toList();
              return Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: ListView(
                    children: [
                      const Text(
                        'Branch',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                                width: 0.80),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(
                                  5.0,
                                  5.0,
                                ),
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                              ),
                            ]),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: branch1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          hint: const Text('Select an item'),
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          elevation: 16,
                          dropdownColor: Colors.grey[100],
                          style: const TextStyle(color: Colors.black),
                          onChanged: (value) {
                            setState(() {
                              branch1 = value;
                            });
                          },
                          items: items.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a branch';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Dropdown(
                        dropdownValue: batchyeardropdownValue,
                        string: batchList,
                        hint: "Batch(Starting Year)",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          autofocus: false,
                          decoration: const InputDecoration(
                            labelText: 'Name: ',
                            labelStyle: TextStyle(fontSize: 20.0),
                            border: OutlineInputBorder(),
                            errorStyle: TextStyle(fontSize: 15),
                          ),
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          maxLength: 12,
                          autofocus: false,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Enrollment Number: ',
                            labelStyle: TextStyle(fontSize: 20.0),
                            border: OutlineInputBorder(),
                            errorStyle: TextStyle(fontSize: 15),
                          ),
                          keyboardType: TextInputType.number,
                          controller: numberController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Enrollment Number';
                            } else if (value.length != 12) {
                              return 'Please Enter Valid Enrollment Number';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          autofocus: false,
                          obscureText: !showPassword,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Password: ',
                            labelStyle: const TextStyle(fontSize: 20.0),
                            border: const OutlineInputBorder(),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Icon(showPassword
                                  ? Icons.lock_open
                                  : Icons.lock_outline),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: _togglePasswordVisibility,
                            ),
                            errorStyle: const TextStyle(fontSize: 15),
                          ),
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Password';
                            } else if (value.length < 6) {
                              return 'Password Provided is too Weak';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  name = nameController.text;
                                  number = numberController.text;
                                  password = passwordController.text;
                                  registration();
                                });
                                login();
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
              );
            }),
      ),
    );
  }
}
