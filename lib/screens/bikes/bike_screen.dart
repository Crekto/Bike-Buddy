import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/user.dart';
import 'package:bike_buddy/screens/bikes/screens/account/account_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/documents/initial_documents_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/expenses/expenses_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/maintenance/maintenance_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/reminders/reminders_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../notifications/notification_service.dart';
import 'database/entities/bike.dart';
import 'edit_bike_screen.dart';

class BikeScreen extends StatefulWidget {
  final MyUser? user;
  final VoidCallback function;
  const BikeScreen({super.key, required this.user, required this.function});

  @override
  State<BikeScreen> createState() => _BikeScreenState();
}

class _BikeScreenState extends State<BikeScreen> {
  Bike? bike;
  @override
  void initState() {
    super.initState();
    bike = widget.user?.bike;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          bike!.nickname,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AccountScreen()));
          },
          child: const Icon(Icons.person_outline),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RemindersScreen()));
            },
            child: const Icon(Icons.notifications_outlined),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              cardColor: myGreyColor,
            ),
            child: PopupMenuButton<int>(
              onSelected: (item) => handleClick(item),
              offset: Offset(0, AppBar().preferredSize.height),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(value: 0, child: Text('Edit')),
                const PopupMenuItem<int>(value: 1, child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.1,
              height: 175,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 15,
                      spreadRadius: 0,
                    ),
                  ]),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                child: Image.network(
                  bike!.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "${bike!.manufacturer} | ${bike!.model}",
            style: bikeTextStyle,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Year: ${bike!.year}",
            style: bikeTextStyle.copyWith(fontSize: 22),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InitialDocumentsSCreen()));
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
                          'Documents',
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
                      builder: (context) => const MaintenanceScreen()));
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
                          'Maintenance',
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
                      builder: (context) => const ExpensesScreen()));
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
                          'Expenses',
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
        ],
      ),
    );
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditBikeScreen(function: widget.function, bike: bike)));

        break;
      case 1:
        showAlertDialog(context);
        break;
    }
  }

  Future<void> deleteFirebaseStorageDirectory(String path) async {
    var list = await FirebaseStorage.instance.ref(path).listAll();
    for (var element in list.items) {
      await element.delete();
    }
    for (var prefix in list.prefixes) {
      await deleteFirebaseStorageDirectory(prefix.fullPath);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: myBlueColor),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        deleteFirebaseStorageDirectory(FirebaseAuth.instance.currentUser!.uid);

        final userDoc = FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid);
        userDoc.delete().then((value) => debugPrint("Documment deleted."),
            onError: (e) => debugPrint(e));

        NotificationService().cancelAllNotifications();
        if (context.mounted) {
          Navigator.pop(context);
        }
        setState(() {
          widget.function();
        });
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: myGreyColor,
      title: const Text("Are you sure?"),
      content: const Text("This will delete all data and it can't be revoked."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
