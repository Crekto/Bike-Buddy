import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/maintenance_record.dart';
import 'package:bike_buddy/screens/bikes/screens/maintenance/components/maintenance_record_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeRangeSelector extends StatefulWidget {
  final List<MaintenanceRecord> maintenanceRecords;
  final Function setFilteredRecords;
  final VoidCallback function;

  const TimeRangeSelector({
    super.key,
    required this.setFilteredRecords,
    required this.maintenanceRecords,
    required this.function,
  });
  @override
  State<TimeRangeSelector> createState() => _TimeRangeSelectorState();
}

class _TimeRangeSelectorState extends State<TimeRangeSelector> {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
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
                style:
                    myTextStyleBold.copyWith(fontSize: 20, color: myBlueColor),
              ),
            ),
          ],
        ),
      ),
    );
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
          }
          filterObjects();
        });
      }
    });
  }

  List<Object> filterObjects() {
    // Filter the list of objects based on the selected date range
    // Return the filtered list of objects
    // Example filtering based on date range:
    List<Object> objects = [];

    // Filter based on the date range
    if (selectedRange == 'All time') {
      // Filter all objects
      //objects = /* ... */;
    } else if (selectedRange == 'This week') {
      debugPrint("THIS WEEK");
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek =
          now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

      List<MaintenanceRecord> filteredList =
          widget.maintenanceRecords.where((object) {
        return object.date.isAfter(startOfWeek) &&
            object.date.isBefore(endOfWeek);
      }).toList();
      widget.setFilteredRecords(listToWidgetList(filteredList));
      //objects = /* ... */;
    } else if (selectedRange == 'This month') {
      // Filter objects for the current month
      //objects = /* ... */;
    } else if (selectedRange == 'This year') {
      // Filter objects for the current year
      //objects = /* ... */;
    } else if (selectedRange == 'Custom range') {
      // Filter objects based on the custom date range
      //objects = /* Filter based on startDate and endDate */;
    }

    return objects;
  }

  List<Widget> listToWidgetList(List<MaintenanceRecord> objects) {
    List<Widget> maintenanceRecordWidgets = [];
    for (var object in objects) {
      maintenanceRecordWidgets.add(MaintenanceRecordCard(
          function: widget.function,
          record: object,
          recordIndex: widget.maintenanceRecords.indexOf(object)));
    }
    return maintenanceRecordWidgets;
  }
}
