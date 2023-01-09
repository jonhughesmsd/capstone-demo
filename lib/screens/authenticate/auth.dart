import 'package:capstone/screens/authenticate/login.dart';
import 'package:capstone/screens/authenticate/sign_up.dart';
import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    // toggle between login and sign up screens
    return isLogin
        ? Login(onClickedSignUp: toggle)
        : SignUp(onClickedSignIn: toggle);
  }

  void toggle() => setState(() => isLogin = !isLogin);
}
