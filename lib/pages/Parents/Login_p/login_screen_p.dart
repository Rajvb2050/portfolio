import 'package:flutter/material.dart';
import 'package:smart_parents/components/background.dart';
import 'package:smart_parents/pages/Parents/Login_p/components_p/login_form_p.dart';
import 'package:smart_parents/pages/Parents/Login_p/components_p/login_screen_top_image_p.dart';

class LoginScreenP extends StatelessWidget {
  const LoginScreenP({Key? key}) : super(key: key);
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
