import 'package:bike_buddy/screens/bikes/database/entities/maintenance_record.dart';

class MaintenanceHistory {
  MaintenanceHistory(this.records);

  List<MaintenanceRecord>? records;

  factory MaintenanceHistory.fromJson(Map<String, dynamic> json) {
    List<MaintenanceRecord> tempRecords = [];
    if (json['records'] != null) {
      json['records'].forEach((record) {
        tempRecords.add(MaintenanceRecord.fromJson(record));
      });
    }
    return MaintenanceHistory(tempRecords);
  }

  Map<String, dynamic> toJson() => {
        'records': records?.map((record) => record.toJson()).toList(),
      };
}
