import 'package:flutter/material.dart';
import 'package:smart_parents/components/background.dart';
import 'package:smart_parents/pages/Admin/Login_a/components_a/login_form_a.dart';
import 'package:smart_parents/pages/Admin/Login_a/components_a/login_screen_top_image_a.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: MobileLoginScreen(),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: <Widget>[
          LoginScreenTopImage(),
          Row(
            children: [
              Spacer(),
              Expanded(
                flex: 8,
                child: LoginForm(),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
