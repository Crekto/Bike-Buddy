import 'package:bike_buddy/screens/auth/login_screen.dart';
import 'package:bike_buddy/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginScreen(switchToSignUp: toggleScreen)
      : RegisterScreen(switchToSignIn: toggleScreen);

  void toggleScreen() {
    setState(() {
      isLogin = !isLogin;
    });
  }
}
