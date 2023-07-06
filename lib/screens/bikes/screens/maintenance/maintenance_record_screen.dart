import 'package:bike_buddy/screens/bikes/database/entities/maintenance_record.dart';
import 'package:bike_buddy/screens/bikes/screens/maintenance/edit_maintenance_record_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';

// ignore: must_be_immutable
class MaintenanceRecordScreen extends StatefulWidget {
  final int recordIndex;
  MaintenanceRecord record;
  final Function function;
  MaintenanceRecordScreen(
      {super.key,
      required this.function,
      required this.record,
      required this.recordIndex});

  @override
  State<MaintenanceRecordScreen> createState() =>
      _MaintenanceRecordScreenState();
}

class _MaintenanceRecordScreenState extends State<MaintenanceRecordScreen> {
  List<Widget> imagesWidget = [];

  @override
  void initState() {
    getImagesWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Maintenance Record"),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 14,
                    children: imagesWidget,
                  ),
                ),
              ),
              const SizedBox(
                height: 42,
              ),
              Text(
                widget.record.type,
                style: bikeTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Serviced at: ${NumberFormat("#,###", "ro_RO").format(widget.record.km)} KM",
                style: myTextStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                "Serviced on: ${DateFormat('dd/M/yyyy').format(widget.record.date)}",
                style: myTextStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(
                height: 6,
              ),
              Visibility(
                visible: widget.record.note?.isNotEmpty == true,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 28,
                    ),
                    Text(
                      "Note:",
                      style: myTextStyleBold.copyWith(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Text(
                      widget.record.note ??= "",
                      style: myTextStyle.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getImagesWidget() {
    imagesWidget = [];

    for (var image in widget.record.images) {
      imagesWidget.add(GestureDetector(
        onTap: () {
          showImageViewer(context, Image.network(image).image,
              swipeDismissible: false);
        },
        child: Container(
          height: 160,
          width: 320,
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.network(image).image,
          )),
        ),
      ));
    }
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditMaintenanceRecordScreen(
                      function: refresh,
                      record: widget.record,
                      recordIndex: widget.recordIndex,
                    )));

        break;
      case 1:
        showAlertDialog(context);
        break;
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
        List<MaintenanceRecord>? maintenanceHistory =
            await readMaintenanceHistory();
        maintenanceHistory!.removeAt(widget.recordIndex);

        final userDoc = FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid);

        userDoc.update({
          "maintenanceRecords":
              maintenanceHistory.map((record) => record.toJson()).toList()
        });
        if (context.mounted) {
          Navigator.pop(context);
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

  void refresh(MaintenanceRecord record) {
    setState(() {
      widget.record = record;
      getImagesWidget();
      widget.function();
    });
  }
}

Future<List<MaintenanceRecord>?> readMaintenanceHistory() async {
  final docUser = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    List<MaintenanceRecord> tempRecords = [];
    if (snapshot.data()!['maintenanceRecords'] != null) {
      snapshot.data()!['maintenanceRecords'].forEach((record) {
        tempRecords.add(MaintenanceRecord.fromJson(record));
      });
    }
    return tempRecords;
  }
  return null;
}
