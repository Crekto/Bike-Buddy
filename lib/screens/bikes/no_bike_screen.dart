import 'package:bike_buddy/screens/bikes/add_bike_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class NoBikeScreen extends StatefulWidget {
  final VoidCallback function;
  const NoBikeScreen({super.key, required this.function});

  @override
  State<NoBikeScreen> createState() => _NoBikeScreenState();
}

class _NoBikeScreenState extends State<NoBikeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Container(
              height: 60,
            ),
            Image.asset('lib/images/no_bike_screen.png'),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddBikeScreen(function: widget.function)));
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(105, 40, 105, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade700,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      color: myBlueColor,
                      child: Center(
                        child: Text(
                          'Add your bike',
                          style: myTextStyleBold.copyWith(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 38,
            ),
            GestureDetector(
              onTap: () => FirebaseAuth.instance.signOut(),
              child: Text(
                "Sign out",
                style:
                    myTextStyleBold.copyWith(fontSize: 18, color: myBlueColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
