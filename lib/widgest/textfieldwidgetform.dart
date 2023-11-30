import 'package:flutter/material.dart';

class TextFieldWidgetForm extends StatefulWidget {
  final String label;
  final String text;
  final ValueChanged<String> onChanged;
  const TextFieldWidgetForm({
    Key? key,
    required this.label,
    required this.text,
    required this.onChanged,
    controller,
  }) : super(key: key);
  @override
  TextFieldWidgetFormState createState() => TextFieldWidgetFormState();
}

class TextFieldWidgetFormState extends State<TextFieldWidgetForm> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text(
              widget.label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextFormField(
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: controller,
            ),
          )
        ],
      );
}
