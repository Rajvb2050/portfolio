import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';

class AddParentPage extends StatefulWidget {
  const AddParentPage({Key? key}) : super(key: key);
  @override
  AddParentPageState createState() => AddParentPageState();
}

class AddParentPageState extends State<AddParentPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  var name = "";
  var number = "";
  var password = "";
  String? child;
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

  CollectionReference parents =
      FirebaseFirestore.instance.collection('Admin/$admin/parents');
  Future<void> addUser() async {
    final snahot = await FirebaseFirestore.instance
        .collection('Admin/$admin/students')
        .where('number', isEqualTo: child)
        .get();
    String? batchyear;
    if (snahot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> doc in snahot.docs) {
        batchyear = doc.get('batch');
      }
    }
    parents
        .doc(number)
        .set({
          'batch': batchyear,
          'name': name,
          'number': number,
          'password': password,
          'branch': branch,
          'child': child,
          'status': true,
        })
        .then((value) => print('parent Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  Future<void> addUsers() {
    return users
        .doc(number)
        .set({'id': number, 'role': 'parents', 'status': true, 'admin': admin})
        .then((value) => print('parent Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  registration() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: "$number@spp.com", password: password)
          .then((value) {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            "Parents Added.",
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
      );
      addUser();
      addUsers();
      clearText();
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
        print("Parent Already exists");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              "Parent Already exists",
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
    email = prefs.getString('faculty');
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
          title: const Text("Add New Parent"),
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
                    .collection('Admin/$admin/students')
                    .where('branch', isEqualTo: branch)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final items = snapshot.data!.docs
                      .map((doc) => doc.get('number'))
                      .toList();
                  return Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: ListView(
                        children: [
                          const Text(
                            'Student',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
                              value: child,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              hint: const Text('Select an item'),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_outlined),
                              elevation: 16,
                              dropdownColor: Colors.grey[100],
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) {
                                setState(() {
                                  child = value;
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
                                  return 'Please select a student';
                                }
                                return null;
                              },
                            ),
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
                              maxLength: 10,
                              autofocus: false,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number: ',
                                labelStyle: TextStyle(fontSize: 20.0),
                                border: OutlineInputBorder(),
                                errorStyle: TextStyle(fontSize: 15),
                              ),
                              keyboardType: TextInputType.number,
                              controller: numberController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Mobile Number';
                                } else if (value.length != 10) {
                                  return 'Please Enter Valid Mobile Number';
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
                })));
  }
}
