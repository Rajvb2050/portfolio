import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/already_have_an_account_acheck.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Admin/Signup_a/signup_screen_a.dart';
import 'package:smart_parents/pages/Admin/forgot_password_a.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/pages/Admin/user_main_a.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  var email = "";
  var password = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  check() async {
    final snapShot = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: email)
        .where('role', isEqualTo: 'admin')
        .where('status', isEqualTo: true)
        .get();
    if (snapShot.docs.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        print(userCredential.user!.uid);
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapShot.docs) {
          admin = doc.get('admin');
        }
        final SharedPreferences prefs = await _prefs;
        await prefs.setString('uid', userCredential.user!.uid);
        await prefs.setString('role', 'admin');
        await prefs.setString('email', email);
        await prefs.setString('pass', password);
        await prefs.setString('id', email);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserMainA(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print("No User Found for that Email");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryLightColor,
              content: Text(
                "No User Found for that Email",
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          print("Wrong Password Provided by User");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryLightColor,
              content: Text(
                "Wrong Password Provided by User",
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          );
        }
      }
    } else {
      print("No User Found for that Email");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            "No User Found for that Email",
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
      );
    }
  }

  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regex.hasMatch(email);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
      child: Column(
        children: [
          TextFormField(
            autofocus: false,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
              errorStyle: TextStyle(fontSize: 15),
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
              autofocus: false,
              obscureText: !_showPassword,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(
                      _showPassword ? Icons.lock_open : Icons.lock_outline),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: _togglePasswordVisibility,
                ),
                errorStyle: const TextStyle(fontSize: 15),
              ),
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Password';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: defaultPadding),
          Container(
            margin: const EdgeInsets.only(left: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        email = emailController.text;
                        password = passwordController.text;
                      });
                      check();
                    }
                  },
                  child: Text(
                    "Login".toUpperCase(),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPassword()),
                      );
                    },
                    child: const Text(
                      "Forgot Password ?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    )),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
