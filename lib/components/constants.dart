import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

var background = 'assets/images/background.jpg';
String? admin;
String? branch;
String? batch;
String? child;
const kPrimaryColor = Color(0xFF255674);
const kPrimaryLightColor = Color.fromARGB(255, 207, 235, 255);
const double defaultPadding = 10.0;
const kSendButtonTextStyle = TextStyle(
  color: kPrimaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);
InputDecoration kMessageTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: kPrimaryLightColor,
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  hintStyle: TextStyle(color: Colors.grey[800]),
  border: InputBorder.none,
);
const kMessageContainerDecoration = BoxDecoration(
  color: kPrimaryLightColor,
  border: Border(
    top: BorderSide(color: kPrimaryColor, width: 2.0),
  ),
);
List<String> days = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
];
List<String> batchList =
    List.generate(100, (index) => (2001 + index).toString());
String daysdropdownValue = DateFormat('EEEE').format(DateTime.now());
String batchyeardropdownValue = DateFormat('yyyy').format(DateTime.now());
const green = Color(0xff00CE2D);
const red = Color(0xffff0800);
