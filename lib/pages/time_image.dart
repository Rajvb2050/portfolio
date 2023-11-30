import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/pages/check.dart';

class MyCustomSplashScreen extends StatefulWidget {
  const MyCustomSplashScreen({super.key});
  @override
  MyCustomSplashScreenState createState() => MyCustomSplashScreenState();
}

class MyCustomSplashScreenState extends State<MyCustomSplashScreen>
    with TickerProviderStateMixin {
  double _fontSize = 2;
  double _textOpacity = 0.0;
  double _containerOpacity = 0.0;
  late AnimationController _controller;
  late Animation<double> animation1;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animation1 = Tween<double>(begin: 40, end: 20).animate(CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        setState(() {
          _textOpacity = 1.0;
        });
      });
    _controller.forward();
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _fontSize = 1.06;
      });
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _containerOpacity = 1;
      });
    });
    Timer(const Duration(seconds: 4), () {
      setState(() {
        Navigator.pushReplacement(context, PageTransition(const Check()));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
      children: [
        Column(
          children: [
            AnimatedContainer(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.fastLinearToSlowEaseIn,
                height: height / _fontSize),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 2000),
              opacity: _textOpacity,
              child: Text(
                ' Welcome, Smart Parents',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: animation1.value,
                ),
              ),
            ),
          ],
        ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.fastLinearToSlowEaseIn,
            opacity: _containerOpacity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.fastLinearToSlowEaseIn,
              height: 350,
              width: 350,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Image.asset('assets/images/Final.png'),
            ),
          ),
        ),
      ],
    ));
  }
}

class PageTransition extends PageRouteBuilder {
  final Widget page;
  PageTransition(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                curve: Curves.fastLinearToSlowEaseIn,
                parent: animation,
                reverseCurve: Curves.fastOutSlowIn);
            return ScaleTransition(
              alignment: Alignment.center,
              scale: animation,
              child: child,
            );
          },
        );
}
