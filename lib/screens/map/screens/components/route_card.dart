import 'dart:math';

import 'package:background_locator_2/location_dto.dart';
import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/route_record.dart';
import 'package:bike_buddy/screens/map/screens/route_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class RouteCard extends StatefulWidget {
  final RouteRecord routeRecord;
  final int routeIndex;
  final VoidCallback parentRefresh;
  const RouteCard(
      {super.key,
      required this.routeRecord,
      required this.routeIndex,
      required this.parentRefresh});

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  final MapController mapController = MapController();
  double distance = 0.0;

  @override
  void initState() {
    super.initState();
    setDistance();
    WidgetsBinding.instance.addPostFrameCallback((_) => moveMap());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDate(widget.routeRecord.startDate),
            style: myTextStyle.copyWith(fontSize: 17),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteScreen(
                    routeRecord: widget.routeRecord,
                    routeIndex: widget.routeIndex,
                    parentRefresh: widget.parentRefresh,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: myBlueColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          center: LatLng(0, 0),
                          zoom: 15,
                          interactiveFlags: InteractiveFlag.none,
                          onTap: (tapPosition, point) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RouteScreen(
                                  routeRecord: widget.routeRecord,
                                  routeIndex: widget.routeIndex,
                                  parentRefresh: widget.parentRefresh,
                                ),
                              ),
                            );
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: '',
                            subdomains: const [],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: widget.routeRecord.routePoints
                                    .map((position) => LatLng(
                                        position.latitude, position.longitude))
                                    .toList(),
                                color: Colors.blue,
                                strokeWidth: 5.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${distance.toStringAsFixed(1)} KM",
                        style: myTextStyleBold.copyWith(fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void moveMap() async {
    List<LocationDto> tempPoints = widget.routeRecord.routePoints;

    if (tempPoints.isNotEmpty) {
      double minLat = tempPoints[0].latitude;
      double maxLat = tempPoints[0].latitude;
      double minLng = tempPoints[0].longitude;
      double maxLng = tempPoints[0].longitude;

      for (var point in tempPoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      LatLngBounds bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(10.0)),
      );
    }
  }

  void setDistance() {
    double totalDistance = 0;
    List<LocationDto> locations = widget.routeRecord.routePoints;

    for (int i = 0; i < locations.length - 1; i++) {
      LocationDto currentLocation = locations[i];
      LocationDto nextLocation = locations[i + 1];

      double lat1 = currentLocation.latitude;
      double lon1 = currentLocation.longitude;
      double lat2 = nextLocation.latitude;
      double lon2 = nextLocation.longitude;

      double distance = _calculateDistanceBetweenPoints(lat1, lon1, lat2, lon2);
      totalDistance += distance;
    }

    setState(() {
      distance = totalDistance;
    });
  }

  double _calculateDistanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  String formatDate(DateTime date) {
    DateTime today = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (today.year == date.year &&
        today.month == date.month &&
        today.day == date.day) {
      return "Today at ${DateFormat("h:mm a").format(date)}";
    } else if (yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day) {
      return "Yesterday at ${DateFormat("h:mm a").format(date)}";
    }
    return "${DateFormat('MMM d, yyyy').format(date)} at ${DateFormat("h:mm a").format(date)}";
  }
}
