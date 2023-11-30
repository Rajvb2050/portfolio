import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';

class AddFacultyPage extends StatefulWidget {
  const AddFacultyPage({Key? key}) : super(key: key);
  @override
  AddFacultyPageState createState() => AddFacultyPageState();
}

class AddFacultyPageState extends State<AddFacultyPage> {
  final _formKey = GlobalKey<FormState>();
  final _prefs = SharedPreferences.getInstance();
  var faculty = "";
  var name = "";
  String? branch1;
  var password = "";
  @override
  void initState() {
    super.initState();
    login();
  }

  final facultyController = TextEditingController();
  final nameController = TextEditingController();
  final branchController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    facultyController.dispose();
    nameController.dispose();
    branchController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  clearText() async {
    facultyController.clear();
    nameController.clear();
    branchController.clear();
    passwordController.clear();
  }

  CollectionReference facultys =
      FirebaseFirestore.instance.collection('Admin/$admin/faculty');
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  registration() async {
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: "$faculty@spf.com", password: password)
          .then((value) {});
      try {
        print("add1................");
        facultys
            .doc(faculty)
            .set({
              'faculty': faculty,
              'name': name,
              'password': password,
              'branch': branch1,
              'status': true
            })
            .then((value) => print('faculty Added'))
            .catchError((error) => print('Failed to Add user: $error'));
        users
            .doc(faculty)
            .set({
              'id': faculty,
              'role': 'faculty',
              'status': true,
              'admin': admin
            })
            .then((value) => print('faculty Added'))
            .catchError((error) => print('Failed to Add user: $error'));
      } on Exception catch (e) {
        print(e.toString());
      }
      print("add2................");
      clearText();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            "Faculty Added.",
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
        print("Faculty Already exists");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              "Faculty Already exists",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      }
    }
  }

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
          title: const Text("Add New Faculty"),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: "Back",
            onPressed: () => Navigator.pop(context),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
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
                            icon:
                                const Icon(Icons.keyboard_arrow_down_outlined),
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
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            maxLength: 4,
                            autofocus: false,
                            decoration: const InputDecoration(
                              labelText: 'Faculty Id: ',
                              labelStyle: TextStyle(fontSize: 20.0),
                              border: OutlineInputBorder(),
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                            keyboardType: TextInputType.number,
                            controller: facultyController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Faculty Id';
                              } else if (value.length != 4) {
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
                                    faculty = facultyController.text;
                                    name = nameController.text;
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
        ));
  }
}
