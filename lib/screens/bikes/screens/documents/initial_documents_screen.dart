import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/notifications/notification_service.dart';
import 'package:bike_buddy/screens/bikes/database/entities/documents.dart';
import 'package:bike_buddy/screens/bikes/screens/documents/driving_license/driving_license_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/documents/id_card/id_card_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/documents/insurance/insurance_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'civ/civ_screen.dart';

class InitialDocumentsSCreen extends StatefulWidget {
  const InitialDocumentsSCreen({super.key});

  @override
  State<InitialDocumentsSCreen> createState() => _InitialDocumentsSCreenState();
}

class _InitialDocumentsSCreenState extends State<InitialDocumentsSCreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Documents?>(
      future: readDocuments(),
      builder: (context, AsyncSnapshot<Documents?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Documents? documents = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Documents"),
            ),
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => IdCardScreen(
                                documents: documents,
                                function: refresh,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 51, 56, 58),
                          blurRadius: 15,
                          offset: Offset(-4, -4),
                        ),
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        color: myBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID Card',
                              style: myTextStyleBold.copyWith(
                                  color: Colors.white, fontSize: 20),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DrivingLicenseScreen(
                                documents: documents,
                                function: refresh,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 51, 56, 58),
                          blurRadius: 15,
                          offset: Offset(-4, -4),
                        ),
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        color: myBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Driving License',
                              style: myTextStyleBold.copyWith(
                                  color: Colors.white, fontSize: 20),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CivScreen(
                                documents: documents,
                                function: refresh,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 51, 56, 58),
                          blurRadius: 15,
                          offset: Offset(-4, -4),
                        ),
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        color: myBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CIV',
                              style: myTextStyleBold.copyWith(
                                  color: Colors.white, fontSize: 20),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InsuranceScreen(
                                documents: documents,
                                function: refresh,
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 51, 56, 58),
                          blurRadius: 15,
                          offset: Offset(-4, -4),
                        ),
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        color: myBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Insurance',
                              style: myTextStyleBold.copyWith(
                                  color: Colors.white, fontSize: 20),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              GestureDetector(
                onTap: () async {
                  NotificationService().showNotification(
                      title: "ID Card is expiring",
                      body: "Your ID Card is expiring in 5 days");
                },
                child: const Text("Test Notificare"),
              ),
            ]),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Documents?> readDocuments() async {
    final docUser = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return Documents.fromJson(snapshot.data()!["documents"]);
    }
    return null;
  }

  void refresh() {
    setState(() {});
  }
}
