import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/main.dart';
import 'package:bike_buddy/screens/auth/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback switchToSignUp;
  const LoginScreen({super.key, required this.switchToSignUp});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 100, 30, 0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: Image.asset(
                  "lib/images/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: 'email',
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  filled: true,
                  fillColor: myGreyColor,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.email(),
                  FormBuilderValidators.required()
                ]),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(
                height: 24,
              ),
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: 'password',
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  filled: true,
                  fillColor: myGreyColor,
                ),
                validator: FormBuilderValidators.required(),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: signIn,
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(myBlueColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)))),
                  child: Text(
                    "Sign In",
                    style: myTextStyleBold.copyWith(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()));
                },
                child: Text(
                  "Forgot Password?",
                  style: myTextStyle.copyWith(fontSize: 16, color: myBlueColor),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              RichText(
                  text: TextSpan(
                      text: "Don't have an account?  ",
                      style: myTextStyle.copyWith(fontSize: 14),
                      children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.switchToSignUp,
                      text: "Sign Up",
                      style: myTextStyleBold.copyWith(
                          fontSize: 14,
                          color: myBlueColor,
                          decoration: TextDecoration.underline),
                    ),
                  ]))
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _formKey.currentState?.fields['email']?.value.trim(),
            password: _formKey.currentState?.fields['password']?.value.trim());
      } on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
        messengerKey.currentState!
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: Colors.red,
          ));
      }
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
