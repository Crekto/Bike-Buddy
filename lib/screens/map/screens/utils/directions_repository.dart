import 'package:bike_buddy/screens/map/screens/utils/directions.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DirectionsRepository {
  static const String baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  late final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Directions>?> getDirections(
      {required List<Marker> markers}) async {
    var origin = markers.first.position;
    var destination = markers.last.position;
    late Response response;
    if (markers.length == 2) {
      response = await _dio.get(baseUrl, queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': dotenv.env['DIRECTIONS_API_KEY'],
        'alternatives': 'true'
      });
    } else {
      String waypoints = '';
      for (int i = 1; i < markers.length - 1; i++) {
        waypoints +=
            '${markers[i].position.latitude},${markers[i].position.longitude}|';
      }
      waypoints = waypoints.substring(0, waypoints.length - 1);
      response = await _dio.get(baseUrl, queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': dotenv.env['DIRECTIONS_API_KEY'],
        'waypoints': waypoints
      });
    }

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
