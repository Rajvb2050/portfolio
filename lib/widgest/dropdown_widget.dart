import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class Dropdown extends StatefulWidget {
  final String dropdownValue;
  final List<String> string;
  final String hint;
  const Dropdown({
    Key? key,
    required this.dropdownValue,
    required this.string,
    required this.hint,
  }) : super(key: key);
  @override
  DropdownState createState() => DropdownState();
}

class DropdownState extends State<Dropdown> {
  late String dropdownValue;
  late List<String> string;
  late String hint;
  void changeState() {
    switch (hint) {
      case "Day":
        daysdropdownValue = dropdownValue;
        break;
      case "Batch(Starting Year)":
        batchyeardropdownValue = dropdownValue;
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.dropdownValue;
    string = widget.string;
    hint = widget.hint;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          hint,
          style: const TextStyle(fontSize: 20),
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
              width: 0.80,
            ),
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
            ],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: dropdownValue,
            icon: const Icon(Icons.keyboard_arrow_down_outlined),
            elevation: 16,
            dropdownColor: Colors.grey[100],
            style: const TextStyle(color: Colors.black),
            underline: Container(height: 0, color: Colors.black),
            onChanged: (String? newval) {
              setState(() {
                dropdownValue = newval!;
                changeState();
              });
            },
            items: string.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
