import 'package:flutter/material.dart';
import 'package:smart_parents/components/background.dart';
import 'package:smart_parents/pages/Admin/Signup_a/components_a/sign_up_top_image_a.dart';
import 'package:smart_parents/pages/Admin/Signup_a/components_a/signup_form_a.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: MobileSignupScreen(),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
