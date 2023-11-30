import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:smart_parents/components/background.dart';
import 'package:smart_parents/pages/Student/Login_s/components_s/login_form_s.dart';
import 'package:smart_parents/pages/Student/Login_s/components_s/login_screen_top_image_s.dart';

class LoginScreenS extends StatelessWidget {
  const LoginScreenS({Key? key}) : super(key: key);
  locationData() async {
    Location location = Location();
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus != PermissionStatus.granted) {
      await location.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    locationData();
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
