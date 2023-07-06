import 'package:background_locator_2/location_dto.dart';
import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/route_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FullscreenMapScreen extends StatefulWidget {
  final RouteRecord routeRecord;
  const FullscreenMapScreen({
    super.key,
    required this.routeRecord,
  });

  @override
  State<FullscreenMapScreen> createState() => _FullscreenMapScreenState();
}

class _FullscreenMapScreenState extends State<FullscreenMapScreen> {
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => moveMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Route",
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(0, 0),
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routeRecord.routePoints
                    .map((position) =>
                        LatLng(position.latitude, position.longitude))
                    .toList(),
                color: Colors.blue,
                strokeWidth: 5,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myBlueColor,
        onPressed: () => moveMap(),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Future<void> moveMap() async {
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
      mapController.rotate(0);

      mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(40.0)),
      );

      mapController.move(
        LatLng((bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2),
        mapController.zoom,
      );
    }
  }
}
