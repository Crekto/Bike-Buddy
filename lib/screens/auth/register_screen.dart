import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback switchToSignIn;
  const RegisterScreen({super.key, required this.switchToSignIn});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(6)
                ]),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 24,
              ),
              FormBuilderTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: 'confirm-password',
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
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
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  (value) {
                    if (value !=
                        _formKey.currentState?.fields['password']?.value) {
                      return "The passwords doesn't match.";
                    }
                    return null;
                  }
                ]),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 24,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: signUp,
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(myBlueColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)))),
                  child: Text(
                    "Sign Up",
                    style: myTextStyleBold.copyWith(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RichText(
                  text: TextSpan(
                      text: "Already have an account?  ",
                      style: myTextStyle.copyWith(fontSize: 14),
                      children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.switchToSignIn,
                      text: "Sign In",
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

  Future signUp() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
