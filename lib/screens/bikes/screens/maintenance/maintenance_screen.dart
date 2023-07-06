import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/maintenance_record.dart';
import 'package:bike_buddy/screens/bikes/screens/maintenance/add_maintenance_record_screen.dart';
import 'package:bike_buddy/screens/bikes/screens/maintenance/components/maintenance_record_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  String selectedRange = 'All time';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<String> ranges = [
    'All time',
    'This week',
    'This month',
    'This year',
    'Custom range',
  ];
  late List<MaintenanceRecord> maintenanceRecords;
  List<Widget> maintenanceRecordWidgets = [];
  int currentPage = 0;
  int pageSize = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Maintenance"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 46, right: 16),
        child: Column(
          children: [
            Center(
              child: Text(
                "Maintenance History",
                style: myTextStyleBold,
              ),
            ),
            const SizedBox(height: 23),
            FutureBuilder<List<MaintenanceRecord>?>(
              future: readMaintenanceHistory(),
              builder:
                  (context, AsyncSnapshot<List<MaintenanceRecord>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data!.isEmpty) {
                    return const Text("No maintenance records yet.");
                  } else {
                    maintenanceRecords = snapshot.data!;
                    maintenanceRecordWidgets = filterRecords();

                    return Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showTimeRangeMenu(context);
                                    },
                                    child: Text(
                                      selectedRange == 'Custom range'
                                          ? "${DateFormat.yMd().format(startDate)} - ${DateFormat.yMd().format(endDate)}"
                                          : selectedRange,
                                      style: myTextStyleBold.copyWith(
                                          fontSize: 20, color: myBlueColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 420),
                            child: Column(
                              children: List.generate(pageSize, (index) {
                                int maintenanceIndex =
                                    currentPage * pageSize + index;
                                return maintenanceIndex <
                                        maintenanceRecordWidgets.length
                                    ? maintenanceRecordWidgets[maintenanceIndex]
                                    : Container();
                              }),
                            ),
                          ),
                          Visibility(
                            visible: maintenanceRecordWidgets.length > pageSize,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (currentPage > 0) {
                                      setState(() {
                                        currentPage--;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.chevron_left,
                                    color: currentPage > 0
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                                Text((currentPage + 1).toString()),
                                GestureDetector(
                                  onTap: () {
                                    if ((currentPage + 1) * pageSize <
                                        maintenanceRecordWidgets.length) {
                                      setState(() {
                                        currentPage++;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: ((currentPage + 1) * pageSize <
                                            maintenanceRecordWidgets.length)
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myBlueColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddMaintenanceRecordScreen(function: refresh)));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
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

  void refresh() {
    setState(() {});
  }

  void showDatePickerDialog(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: startDate,
      end: endDate,
    );

    final selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialDateRange: initialDateRange,
      initialEntryMode: DatePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: myBlueColor,
              surface: myBlueColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: myBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (selectedDateRange != null) {
      setState(() {
        startDate = selectedDateRange.start;
        endDate = selectedDateRange.end;
        setFilterRecords(filterRecords());
      });
    }
  }

  void showTimeRangeMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    final List<PopupMenuEntry<String>> menuItems = [
      const PopupMenuItem<String>(
        value: 'All time',
        child: Text('All time'),
      ),
      const PopupMenuItem<String>(
        value: 'This week',
        child: Text('This week'),
      ),
      const PopupMenuItem<String>(
        value: 'This month',
        child: Text('This month'),
      ),
      const PopupMenuItem<String>(
        value: 'This year',
        child: Text('This year'),
      ),
      const PopupMenuItem<String>(
        value: 'Custom range',
        child: Text('Custom range'),
      ),
    ];

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        115,
        buttonPosition.dy,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height,
      ),
      color: myGreyColor,
      items: menuItems,
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedRange = value;
          if (selectedRange == "Custom range") {
            showDatePickerDialog(context);
          } else {
            setFilterRecords(filterRecords());
          }
        });
      }
    });
  }

  List<Widget> filterRecords() {
    List<Widget> filteredListWidget = [];
    if (selectedRange == 'All time') {
      filteredListWidget = listToWidgetList(maintenanceRecords);
    } else if (selectedRange == 'This week') {
      DateTime now = DateTime.now();
      now = DateTime(now.year, now.month, now.day);
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));

      List<MaintenanceRecord> filteredList = maintenanceRecords.where((record) {
        return record.date.compareTo(startOfWeek) >= 0 &&
            record.date.compareTo(endOfWeek) <= 0;
      }).toList();
      filteredListWidget = listToWidgetList(filteredList);
    } else if (selectedRange == 'This month') {
      DateTime now = DateTime.now();

      List<MaintenanceRecord> filteredList = maintenanceRecords.where((record) {
        return record.date.year == now.year && record.date.month == now.month;
      }).toList();
      filteredListWidget = listToWidgetList(filteredList);
    } else if (selectedRange == 'This year') {
      DateTime now = DateTime.now();

      List<MaintenanceRecord> filteredList = maintenanceRecords.where((record) {
        return record.date.year == now.year;
      }).toList();
      filteredListWidget = listToWidgetList(filteredList);
    } else if (selectedRange == 'Custom range') {
      List<MaintenanceRecord> filteredList = maintenanceRecords.where((record) {
        return record.date.compareTo(startDate) >= 0 &&
            record.date.compareTo(endDate) <= 0;
      }).toList();
      filteredListWidget = listToWidgetList(filteredList);
    }

    return filteredListWidget;
  }

  void setFilterRecords(List<Widget> filteredRecordWidgets) {
    setState(() {
      maintenanceRecordWidgets = filteredRecordWidgets;
    });
  }

  List<Widget> listToWidgetList(List<MaintenanceRecord> filteredObjects) {
    List<Widget> maintenanceRecordWidgets = [];
    for (var object in filteredObjects) {
      maintenanceRecordWidgets.add(MaintenanceRecordCard(
          function: refresh,
          record: object,
          recordIndex: maintenanceRecords.indexOf(object)));
    }
    return maintenanceRecordWidgets;
  }
}
