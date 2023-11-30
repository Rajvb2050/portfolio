import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/already_have_an_account_acheck.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Admin/Login_a/login_screen_a.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);
  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  CollectionReference admin = FirebaseFirestore.instance.collection('Admin');
  var email = "";
  var password = "";
  var confirmPassword = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regex.hasMatch(email);
  }

  bool isValidPasswordUppercase(String password) {
    final RegExp upperCase = RegExp(r'[A-Z]');
    return upperCase.hasMatch(password);
  }

  bool isValidPasswordLowercase(String password) {
    final RegExp lowerCase = RegExp(r'[a-z]');
    return lowerCase.hasMatch(password);
  }

  bool isValidPasswordNumber(String password) {
    final RegExp number = RegExp(r'[0-9]');
    return number.hasMatch(password);
  }

  bool isValidPasswordSpecialChar(String password) {
    final RegExp specialChar = RegExp(r'[!@#\$%\^&\*]');
    return specialChar.hasMatch(password);
  }

  Future<void> addUser() {
    return admin
        .doc(email)
        .set({'email': email, 'password': password})
        .then((value) => print('admin Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  Future<void> addUsers() {
    return users
        .doc(email)
        .set({'id': email, 'role': 'admin', 'status': true, 'admin': email})
        .then((value) => print('admin Added'))
        .catchError((error) => print('Failed to Add user: $error'));
  }

  registration() async {
    if (password == confirmPassword) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        print(userCredential);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              "Registered Successfully. Please Login..",
              style: TextStyle(fontSize: 20.0, color: Colors.black),
            ),
          ),
        );
        addUser();
        addUsers();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
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
          print("Account Already exists");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryLightColor,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          );
        }
      }
    } else {
      print("Password and Confirm Password doesn't match");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            "Password and Confirm Password doesn't match",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
      );
    }
  }

  bool _showPassword = false;
  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSaved: (email) {},
              decoration: const InputDecoration(
                hintText: "Your email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Email';
                } else if (!isValidEmail(value)) {
                  return 'Please Enter Valid Email';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: "Your password",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Icon(
                        _showPassword ? Icons.lock_open : Icons.lock_outline),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long.';
                  } else if (!isValidPasswordUppercase(value)) {
                    return 'Password must contain an uppercase letter.';
                  } else if (!isValidPasswordLowercase(value)) {
                    return 'Password must contain a lowercase letter.';
                  } else if (!isValidPasswordNumber(value)) {
                    return 'Password must contain a number.';
                  } else if (!isValidPasswordSpecialChar(value)) {
                    return 'Password must contain a special character.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: "Confirm Your password",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Icon(
                        _showPassword ? Icons.lock_open : Icons.lock_outline),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                controller: confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Confirm Password';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    email = emailController.text;
                    password = passwordController.text;
                    confirmPassword = confirmPasswordController.text;
                  });
                  registration();
                }
              },
              child: Text("Sign Up".toUpperCase()),
            ),
            const SizedBox(height: defaultPadding),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
