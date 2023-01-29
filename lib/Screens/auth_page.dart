import 'package:flutter/material.dart';
import 'package:fluttercharts/Screens/login_page.dart';
import 'package:fluttercharts/Screens/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage();

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //initially show the login page
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
