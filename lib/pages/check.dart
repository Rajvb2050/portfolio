import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/internetcheck.dart';
import 'package:smart_parents/pages/Faculty/user_main_f.dart';
import 'package:smart_parents/pages/Parents/user_main_p.dart';
import 'package:smart_parents/pages/Student/user_main_s.dart';
import 'package:smart_parents/pages/option.dart';
import 'package:smart_parents/pages/Admin/user_main_a.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Check extends StatefulWidget {
  const Check({Key? key}) : super(key: key);
  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  @override
  void initState() {
    super.initState();
    InternetPopup().initialize(context: context);
  }

  final _prefs = SharedPreferences.getInstance();
  String? role;
  Future<bool> checkLoginStatus() async {
    bool loggedIn = false;
    final SharedPreferences prefs = await _prefs;
    User? user = FirebaseAuth.instance.currentUser;
    if (user!.email != null) {
      loggedIn = true;
    } else {
      loggedIn = false;
    }
    if (loggedIn) {
      final String? action = prefs.getString('uid');
      if (action != user.uid) {
        await prefs.clear();
        FirebaseAuth.instance.signOut();
        return true;
      }
      final String? id = prefs.getString('id');
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Users').doc(id).get();
      var data = snapshot.data();
      var arole = data!['role'];
      var status = data['status'];
      if (status == true) {
        if (arole == 'admin') {
          role = arole;
        } else if (arole == 'faculty') {
          role = arole;
        } else if (arole == 'student') {
          role = arole;
        } else if (arole == 'parents') {
          role = arole;
        }
      } else {
        await prefs.clear();
        FirebaseAuth.instance.signOut();
      }
      return true;
    } else {
      await prefs.clear();
      FirebaseAuth.instance.signOut();
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == false) {
            return const Option();
          } else if (snapshot.hasData) {
            if (role == 'admin') {
              return const UserMainA();
            } else if (role == 'faculty') {
              return const UserMainF();
            } else if (role == 'student') {
              return const UserMainS();
            } else if (role == 'parents') {
              return const ParentsScreen();
            } else {
              return const Option();
            }
          } else {
            return const Option();
          }
        });
  }
}
