import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Text(
          "Admin Sign Up".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset(
                "assets/images/Admin.png",
                height: screenWidth * 0.5,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
