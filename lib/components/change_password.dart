import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/option.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);
  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  var oldpassword = "";
  var newpassword = "";
  var confirmpassword = "";
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  final _prefs = SharedPreferences.getInstance();
  Future<void> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword == confirmPassword) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: oldPassword,
      );
      try {
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        await FirebaseAuth.instance.signOut();
        final SharedPreferences prefs = await _prefs;
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Option(),
            ),
            (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kPrimaryLightColor,
            content: Text(
              'Password changed successfully!',
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: kPrimaryLightColor,
              content: Text(
                'The old password is incorrect.',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kPrimaryLightColor,
          content: Text(
            "Password and Confirm Password doesn't match",
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
          title:
              const Text("Change Password", style: TextStyle(fontSize: 30.0)),
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
                    autofocus: false,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Old Password: ',
                      hintText: 'Enter Old Password',
                      labelStyle: TextStyle(fontSize: 20.0),
                      errorStyle: TextStyle(fontSize: 15),
                    ),
                    controller: oldPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Old Password';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    autofocus: false,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password: ',
                      hintText: 'Enter New Password',
                      labelStyle: TextStyle(fontSize: 20.0),
                      border: OutlineInputBorder(),
                      errorStyle: TextStyle(fontSize: 15),
                    ),
                    controller: newPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter New Password';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    autofocus: false,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password: ',
                      hintText: 'Enter Confirm New Password',
                      labelStyle: TextStyle(fontSize: 20.0),
                      border: OutlineInputBorder(),
                      errorStyle: TextStyle(fontSize: 15),
                    ),
                    controller: confirmNewPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Confirm Password';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        oldpassword = oldPasswordController.text;
                        newpassword = newPasswordController.text;
                        confirmpassword = confirmNewPasswordController.text;
                        changePassword(
                            oldpassword, newpassword, confirmpassword);
                      });
                    }
                  },
                  child: const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
