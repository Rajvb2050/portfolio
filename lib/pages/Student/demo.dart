import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DoubleBackToCloseApp extends StatefulWidget {
  const DoubleBackToCloseApp({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  DoubleBackToCloseAppState createState() => DoubleBackToCloseAppState();
}

class DoubleBackToCloseAppState extends State<DoubleBackToCloseApp> {
  DateTime? _lastTimeBackButtonPressed;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastTimeBackButtonPressed == null ||
            now.difference(_lastTimeBackButtonPressed!) >
                const Duration(seconds: 2)) {
          _lastTimeBackButtonPressed = now;
          Fluttertoast.showToast(
            msg: "Press back again to exit",
            backgroundColor: Colors.grey[700],
            textColor: Colors.white,
          );
          return false;
        } else {
          return true;
        }
      },
      child: widget.child,
    );
  }
}
