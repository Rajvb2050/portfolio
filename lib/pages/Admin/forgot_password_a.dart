import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Admin/Login_a/login_screen_a.dart';
import 'package:smart_parents/pages/Admin/Signup_a/signup_screen_a.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);
  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  var email = "";
  final emailController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  resetPassword() async {
    final snapShot = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: email)
        .where('role', isEqualTo: 'admin')
        .where('status', isEqualTo: true)
        .get();
    if (snapShot.docs.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              'Password Reset Email has been sent !',
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryLightColor,
              content: Text(
                'No user found for that email.',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          );
        }
      }
    } else {
      print('No user found for that email.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            'No user found for that email.',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Reset Password"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: const Text(
              'Reset Link will be sent to your email id !',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        autofocus: false,
                        decoration: const InputDecoration(
                          labelText: 'Email: ',
                          labelStyle: TextStyle(fontSize: 20.0),
                          border: OutlineInputBorder(),
                          errorStyle: TextStyle(fontSize: 15),
                        ),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Email';
                          } else if (!value.contains('@')) {
                            return 'Please Enter Valid Email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                              });
                              resetPassword();
                            }
                          },
                          child: const Text(
                            'Send Email',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        TextButton(
                          onPressed: () => {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false)
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an Account? "),
                        TextButton(
                            onPressed: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ))
                                },
                            child: const Text(
                              'Signup',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
