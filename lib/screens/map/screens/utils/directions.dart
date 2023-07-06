import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  late final LatLngBounds bounds;
  late final List<PointLatLng> polylinePoints;
  late final int distance;
  late final int duration;

  Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });

  static List<Directions>? fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) return null;

    List<Directions> tempDirections = [];

    for (int i = 0; i < 3; i++) {
      if (i > map['routes'].length - 1) {
        return tempDirections;
      }
      final data = Map<String, dynamic>.from(map['routes'][i]);
      final northeast = data['bounds']['northeast'];
      final southwest = data['bounds']['southwest'];
      final bounds = LatLngBounds(
          northeast: LatLng(northeast['lat'], northeast['lng']),
          southwest: LatLng(southwest['lat'], southwest['lng']));

      int distanceValue = 0;
      int durationValue = 0;

      if ((data['legs'] as List).isNotEmpty) {
        for (var leg in data['legs']) {
          distanceValue += leg['distance']['value'] as int;
          durationValue += leg['duration']['value'] as int;
        }
      }

      tempDirections.add(Directions(
          bounds: bounds,
          polylinePoints: PolylinePoints()
              .decodePolyline(data['overview_polyline']['points']),
          distance: distanceValue,
          duration: durationValue));
    }

    return tempDirections;
  }
}
