import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/maintenance_record.dart';
import 'package:bike_buddy/screens/bikes/screens/maintenance/maintenance_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceRecordCard extends StatelessWidget {
  final int recordIndex;
  final MaintenanceRecord record;
  final VoidCallback function;
  const MaintenanceRecordCard(
      {super.key,
      required this.function,
      required this.record,
      required this.recordIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MaintenanceRecordScreen(
                      function: function,
                      record: record,
                      recordIndex: recordIndex)));
        },
        child: Container(
          width: double.infinity,
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
                  const SizedBox(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        record.type,
                        style: myTextStyleBold.copyWith(fontSize: 20),
                      ),
                      Text(
                        DateFormat('dd/M/yyyy').format(record.date),
                        style: myTextStyle.copyWith(fontSize: 18),
                      ),
                      Text(
                        "${NumberFormat("#,###", "ro_RO").format(record.km)} KM",
                        style: myTextStyle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
