import 'package:flutter/material.dart';
import 'package:smart_parents/components/background.dart';
import 'package:smart_parents/pages/Admin/Login_a/login_screen_a.dart';
import 'package:smart_parents/pages/Faculty/Login_f/login_screen_s.dart';
import 'package:smart_parents/pages/Parents/Login_p/login_screen_p.dart';
import 'package:smart_parents/pages/Student/Login_s/login_screen_s.dart';

class Option extends StatefulWidget {
  const Option({Key? key}) : super(key: key);
  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.4;
    double size = MediaQuery.of(context).size.width * 0.06;
    return Background(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: size,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Admin.png',
                            width: screenWidth,
                          ),
                          const SizedBox(height: 8),
                          const Text("Admin", style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreenF()),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Faculty.png',
                            width: screenWidth,
                          ),
                          const SizedBox(height: 8),
                          const Text("Faculty",
                              style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: size,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreenS()),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Student.png',
                            width: screenWidth,
                          ),
                          const SizedBox(height: 8),
                          const Text("Student",
                              style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreenP()),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/Parents.png',
                            width: screenWidth,
                          ),
                          const SizedBox(height: 8),
                          const Text("Parents",
                              style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
