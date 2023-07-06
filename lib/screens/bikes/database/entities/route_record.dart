import 'package:background_locator_2/location_dto.dart';

class RouteRecord {
  RouteRecord(
    this.routePoints,
    this.startDate,
  );

  List<LocationDto> routePoints;
  DateTime startDate;

  factory RouteRecord.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonRoutePoints = json['routePoints'];
    List<LocationDto> routePoints = jsonRoutePoints
        .map((jsonPoint) => LocationDto.fromJson(jsonPoint))
        .toList();
    return RouteRecord(routePoints, json['startDate'].toDate());
  }

  Map<String, dynamic> toJson() => {
        'routePoints': routePoints.map((point) => point.toJson()).toList(),
        'startDate': startDate,
      };
}
