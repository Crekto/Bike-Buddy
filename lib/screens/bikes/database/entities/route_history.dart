import 'package:bike_buddy/screens/bikes/database/entities/route_record.dart';

class RouteHistory {
  RouteHistory(this.records);

  List<RouteRecord>? records;

  factory RouteHistory.fromJson(Map<String, dynamic> json) {
    List<RouteRecord> tempRoutes = [];
    if (json['routes'] != null) {
      json['routes'].forEach((record) {
        tempRoutes.add(RouteRecord.fromJson(record));
      });
    }
    return RouteHistory(tempRoutes);
  }

  Map<String, dynamic> toJson() => {
        'routes': records?.map((record) => record.toJson()).toList(),
      };
}
