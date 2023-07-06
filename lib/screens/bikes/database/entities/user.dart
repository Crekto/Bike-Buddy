import 'package:bike_buddy/screens/bikes/database/entities/bike.dart';
import 'package:bike_buddy/screens/bikes/database/entities/documents.dart';
import 'package:bike_buddy/screens/bikes/database/entities/expense.dart';
import 'maintenance_record.dart';

class MyUser {
  Bike? bike;
  Documents? documents;
  List<MaintenanceRecord>? maintenanceRecords;
  List<Expense>? expenses;

  MyUser(this.bike, this.documents, this.maintenanceRecords, this.expenses);

  factory MyUser.fromJson(Map<String, dynamic> json) {
    List<MaintenanceRecord> tempRecords = [];
    if (json['maintenanceRecords'] != null) {
      json['maintenanceRecords'].forEach((record) {
        tempRecords.add(MaintenanceRecord.fromJson(record));
      });
    }

    List<Expense> tempExpenses = [];
    if (json['expenses'] != null) {
      json['expenses'].forEach((expense) {
        tempExpenses.add(Expense.fromJson(expense));
      });
    }

    return MyUser(
        json['bike'] != null ? Bike.fromJson(json['bike']) : null,
        json['documents'] != null
            ? Documents.fromJson(json['documents'])
            : null,
        tempRecords,
        tempExpenses);
  }

  Map<String, dynamic> toJson() => {
        'bike': bike?.toJson(),
        'documents': documents?.toJson(),
        'maintenanceRecords':
            maintenanceRecords?.map((record) => record.toJson()).toList(),
        'expenses': expenses?.map((expense) => expense.toJson()).toList(),
      };
}
