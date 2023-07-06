import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: SingleChildScrollView(
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: resetPassword,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(myBlueColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)))),
                    child: Text(
                      "Reset Password",
                      style: myTextStyleBold.copyWith(
                          fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future resetPassword() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _formKey.currentState?.fields['email']?.value.trim(),
        );
        messengerKey.currentState!
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text("Check your email for password reset instructions."),
            backgroundColor: Colors.green,
          ));
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      } on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
        messengerKey.currentState!
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: Colors.red,
          ));
        Navigator.of(context).pop();
      }
    }
  }
}
