import 'package:flutter/material.dart';
import 'package:smart_parents/components/background.dart';
import 'package:smart_parents/pages/Faculty/Login_f/components_f/login_form_f.dart';
import 'package:smart_parents/pages/Faculty/Login_f/components_f/login_screen_top_image_f.dart';

class LoginScreenF extends StatelessWidget {
  const LoginScreenF({Key? key}) : super(key: key);
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
