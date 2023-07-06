import 'package:bike_buddy/screens/bikes/bike_screen.dart';
import 'package:bike_buddy/screens/bikes/database/entities/user.dart';
import 'package:bike_buddy/screens/bikes/no_bike_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BikesScreen extends StatefulWidget {
  const BikesScreen({super.key});

  @override
  State<BikesScreen> createState() => _BikesScreenState();
}

class _BikesScreenState extends State<BikesScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser?>(
      future: readUserBike(),
      builder: (context, AsyncSnapshot<MyUser?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) return NoBikeScreen(function: refresh);

          return BikeScreen(user: snapshot.data, function: refresh);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<MyUser?> readUserBike() async {
    var docUser = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return MyUser.fromJson(snapshot.data()!);
    }
    return null;
  }

  void refresh() {
    setState(() {});
  }
}
