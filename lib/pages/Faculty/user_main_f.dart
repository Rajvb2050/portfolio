import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/Faculty/dashboard_f.dart';
import 'package:smart_parents/pages/Faculty/profile_screen_f.dart';
import 'package:smart_parents/pages/option.dart';

class UserMainF extends StatefulWidget {
  const UserMainF({Key? key}) : super(key: key);
  @override
  UserMainState createState() => UserMainState();
}

class UserMainState extends State<UserMainF> {
  int _selectedIndex = 0;
  final _prefs = SharedPreferences.getInstance();
  String? id;
  @override
  void initState() {
    adminget();
    super.initState();
    Timer(const Duration(seconds: 5), () {
      subscribeUserForNotifications();
    });
  }

  Future<void> subscribeUserForNotifications() async {
    final SharedPreferences prefs = await _prefs;
    id = prefs.getString('id');
    bool userProvidedPrivacyConsent =
        await OneSignal.shared.userProvidedPrivacyConsent();
    if (!userProvidedPrivacyConsent) {
      print(
          "User has not provided privacy consent yet. Cannot subscribe for notifications.");
      return;
    }
    await OneSignal.shared.promptUserForPushNotificationPermission();
    String deviceToken = await OneSignal.shared
        .getDeviceState()
        .then((deviceState) => deviceState!.userId!);
    await FirebaseFirestore.instance
        .collection('Admin/$admin/faculty')
        .doc(id)
        .set({'notification_token': deviceToken}, SetOptions(merge: true));
  }

  adminget() async {
    final SharedPreferences prefs = await _prefs;
    var pid = prefs.getString('id');
    final snapShot = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: pid)
        .get();
    if (snapShot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapShot.docs) {
        admin = doc.get('admin');
      }
    }
    print(admin);
    final snaphot = await FirebaseFirestore.instance
        .collection('Admin/$admin/faculty')
        .where('faculty', isEqualTo: pid)
        .get();
    if (snaphot.docs.isNotEmpty) {
      for (DocumentSnapshot<Map<String, dynamic>> doc in snaphot.docs) {
        branch = doc.get('branch');
      }
    }
    print(branch);
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const Dashboard(),
    const ProfileF()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  delete() async {
    final SharedPreferences prefs = await _prefs;
    final success = await prefs.clear();
    print(success);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return false;
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(background),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  onPressed: () async => {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm Logout"),
                          content:
                              const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text("Logout"),
                              onPressed: () async {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    });
                                try {
                                  await FirebaseAuth.instance.signOut();
                                  delete();
                                  await OneSignal.shared.removeExternalUserId();
                                  try {
                                    final documentReference = FirebaseFirestore
                                        .instance
                                        .collection("Admin/$admin/faculty")
                                        .doc(id);
                                    await documentReference.update({
                                      "notification_token": FieldValue.delete(),
                                    });
                                    print(
                                        "Field 'notification_token' deleted successfully from document $id");
                                  } catch (e) {
                                    print('Error deleting field: $e');
                                  }
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Option(),
                                      ),
                                      (route) => false);
                                } catch (e) {
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: kPrimaryLightColor,
                                        content: Text(
                                          'Failed to logout: $e',
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black),
                                        )),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    )
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: _widgetOptions.elementAt(_selectedIndex),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: kPrimaryLightColor,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GNav(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    activeColor: Colors.white,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    tabBackgroundColor: kPrimaryColor,
                    tabs: const [
                      GButton(
                        icon: Icons.home,
                        text: 'Home',
                      ),
                      GButton(
                        icon: Icons.account_circle,
                        text: 'Profile',
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
