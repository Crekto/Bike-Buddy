import 'dart:math';
import 'package:background_locator_2/location_dto.dart';
import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/database/entities/route_record.dart';
import 'package:bike_buddy/screens/map/screens/components/custom_expansion_panel.dart';
import 'package:bike_buddy/screens/map/screens/fullscreen_map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeline_tile/timeline_tile.dart';

class RouteScreen extends StatefulWidget {
  final RouteRecord routeRecord;
  final int routeIndex;
  final VoidCallback parentRefresh;
  const RouteScreen(
      {super.key,
      required this.routeRecord,
      required this.routeIndex,
      required this.parentRefresh});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final MapController map1Controller = MapController();
  final MapController map2Controller = MapController();
  List<Widget> timelineWidgets = [];
  double distance = 0.0;
  int durationSeconds = 0;

  double maxSpeed = 0.0;
  late DateTime maxSpeedTime;
  double maxSpeedDistance = 0.0;
  double avgSpeed = 0.0;

  double maxElevation = 0.0;
  late DateTime maxElevationTime;
  double maxElevationDistance = 0.0;
  double elevationGain = 0;

  @override
  void initState() {
    setDuration();
    setDistance();
    setElevation();
    setSpeed();
    setTimelineWidgets();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveMap(map1Controller);
      moveMap(map2Controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Route",
        ),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              cardColor: myGreyColor,
            ),
            child: PopupMenuButton<int>(
              offset: Offset(0, AppBar().preferredSize.height),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 1,
                  child: const Text('Delete'),
                  onTap: () {
                    deleteRoute(widget.routeRecord);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: FlutterMap(
                mapController: map1Controller,
                options: MapOptions(
                    center: LatLng(0, 0),
                    zoom: 15,
                    interactiveFlags: InteractiveFlag.none),
                children: [
                  TileLayer(
                    urlTemplate: '',
                    subdomains: const [],
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
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "On ${DateFormat('MMM d, yyyy').format(widget.routeRecord.startDate)}",
              style: myTextStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              thickness: 1,
              indent: 15,
              endIndent: 15,
              color: Color.fromARGB(70, 255, 255, 255),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "DURATION",
                      style: myTextStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      formatDuration(durationSeconds),
                      style: myTextStyleBold.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "DISTANCE",
                      style: myTextStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      "${distance.toStringAsFixed(1)} km",
                      style: myTextStyleBold.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              thickness: 1,
              indent: 15,
              endIndent: 15,
              color: Color.fromARGB(70, 255, 255, 255),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomExpansionPanel(
              title: "See stats of this route",
              body: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                    color: Color.fromARGB(70, 255, 255, 255),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "MAX SPEED",
                            style: myTextStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            "${maxSpeed.toStringAsFixed(1)} km/h",
                            style: myTextStyleBold.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "AVG SPEED",
                            style: myTextStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            "${avgSpeed.toStringAsFixed(1)} km/h",
                            style: myTextStyleBold.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 34, 28, 0),
                    child: SizedBox(
                      height: 200,
                      child: LineChart(createSpeedLineChartData()),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Divider(
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                    color: Color.fromARGB(70, 255, 255, 255),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "MAX ELEVATION",
                            style: myTextStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            "${maxElevation.toStringAsFixed(1)} m",
                            style: myTextStyleBold.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "ELEVATION GAIN",
                            style: myTextStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            "${elevationGain.toStringAsFixed(1)} m",
                            style: myTextStyleBold.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 34, 28, 30),
                    child: SizedBox(
                      height: 200,
                      child: LineChart(createElevationLineChartData()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 1,
              indent: 15,
              endIndent: 15,
              color: Color.fromARGB(70, 255, 255, 255),
            ),
            Column(children: timelineWidgets),
          ],
        ),
      ),
    );
  }

  Future<void> moveMap(MapController mapController) async {
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

      mapController.move(
        LatLng((bounds.southWest.latitude + bounds.northEast.latitude) / 2,
            (bounds.southWest.longitude + bounds.northEast.longitude) / 2),
        mapController.zoom,
      );
    }
  }

  Future<void> deleteRoute(RouteRecord route) async {
    List<RouteRecord>? routes = await readRouteHistory();
    routes!.removeAt(widget.routeIndex);
    final routerDoc = FirebaseFirestore.instance
        .collection("users")
        .doc("${FirebaseAuth.instance.currentUser?.uid}-route");

    routerDoc.update(
        {"routeHistory": routes.map((route) => route.toJson()).toList()});
    if (context.mounted) {
      Navigator.pop(context);
      widget.parentRefresh();
    }
  }

  Future<List<RouteRecord>?> readRouteHistory() async {
    final routerDoc = FirebaseFirestore.instance
        .collection("users")
        .doc("${FirebaseAuth.instance.currentUser?.uid}-route");
    final snapshot = await routerDoc.get();
    if (snapshot.exists) {
      List<RouteRecord> tempRoutes = [];
      if (snapshot.data()!['routeHistory'] != null) {
        snapshot.data()!['routeHistory'].forEach((record) {
          tempRoutes.add(RouteRecord.fromJson(record));
        });
      }
      return tempRoutes;
    }
    return null;
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

  String formatDuration(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600;
    int minutes = (durationInSeconds ~/ 60) % 60;
    int seconds = durationInSeconds % 60;

    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = seconds.toString().padLeft(2, '0');

    return '${hours > 0 ? "$hours:" : ""}$minutesString:$secondsString';
  }

  void setDuration() {
    setState(() {
      durationSeconds = widget.routeRecord.routePoints.length;
    });
  }

  void setDistance() {
    setState(() {
      distance = calculateDistance(widget.routeRecord.routePoints.length);
    });
  }

  double calculateDistance(int tillIndex) {
    double totalDistance = 0;
    List<LocationDto> locations = widget.routeRecord.routePoints;

    for (int i = 0; i < tillIndex - 1; i++) {
      LocationDto currentLocation = locations[i];
      LocationDto nextLocation = locations[i + 1];
      if ((currentLocation.time - nextLocation.time).abs() <= 1500) {
        double lat1 = currentLocation.latitude;
        double lon1 = currentLocation.longitude;
        double lat2 = nextLocation.latitude;
        double lon2 = nextLocation.longitude;

        double distance =
            _calculateDistanceBetweenPoints(lat1, lon1, lat2, lon2);
        totalDistance += distance;
      }
    }

    return totalDistance;
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

  void setElevation() {
    double tempMaxElevation = 0.0;
    DateTime tempMaxElevationTime = DateTime.now();
    double tempMaxElevationDistance = 0.0;
    double tempElevationGain = 0;

    List<LocationDto> locations = widget.routeRecord.routePoints;

    for (int i = 0; i < locations.length - 1; i++) {
      if (locations[i].altitude > tempMaxElevation) {
        tempMaxElevation = locations[i].altitude;
        tempMaxElevationTime =
            DateTime.fromMillisecondsSinceEpoch(locations[i].time.toInt());
        tempMaxElevationDistance = calculateDistance(i);
      }
      double altitudeDiff = locations[i + 1].altitude - locations[i].altitude;
      if (altitudeDiff > 0) {
        tempElevationGain += altitudeDiff;
      }
    }
    setState(() {
      maxElevation = tempMaxElevation;
      maxElevationTime = tempMaxElevationTime;
      maxElevationDistance = tempMaxElevationDistance;
      elevationGain = tempElevationGain;
    });
  }

  void setSpeed() {
    double tempMaxSpeed = 0;
    DateTime tempMaxSpeedTime = DateTime.now();
    double tempMaxSpeedDistance = 0.0;
    double tempTotalSpeed = 0;

    List<LocationDto> locations = widget.routeRecord.routePoints;

    for (int i = 0; i < locations.length - 1; i++) {
      tempTotalSpeed = tempTotalSpeed + locations[i].speed * 3.6;
      if (locations[i].speed * 3.6 > tempMaxSpeed) {
        tempMaxSpeed = locations[i].speed * 3.6;
        tempMaxSpeedTime =
            DateTime.fromMillisecondsSinceEpoch(locations[i].time.toInt());
        tempMaxSpeedDistance = calculateDistance(i);
      }
    }

    setState(() {
      maxSpeed = tempMaxSpeed;
      maxSpeedTime = tempMaxSpeedTime;
      maxSpeedDistance = tempMaxSpeedDistance;
      avgSpeed = tempTotalSpeed / locations.length;
    });
  }

  // Speed Line Chart

  List<double> movingAverageFilter(List<double> values, int windowSize) {
    List<double> filteredValues = [];

    for (int i = 0; i < values.length; i++) {
      if (values[i] < avgSpeed) {
        double sum = values[i];
        int count = 1;

        for (int j = 1; j <= windowSize; j++) {
          if (i - j >= 0) {
            sum += values[i - j];
            count++;
          }
          if (i + j < values.length) {
            sum += values[i + j];
            count++;
          }
        }

        filteredValues.add(sum / count);
      } else {
        filteredValues.add(values[i]);
      }
    }

    return filteredValues;
  }

  LineChartData createSpeedLineChartData() {
    List<FlSpot> spots = [];

    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    List<double> speeds = widget.routeRecord.routePoints
        .map((location) => location.speed * 3.6)
        .toList();

    List<double> filteredSpeeds =
        movingAverageFilter(speeds, speeds.length ~/ 100);
    filteredSpeeds[0] = 0;
    for (int i = 0; i < filteredSpeeds.length; i += 1) {
      String tempSpeed = filteredSpeeds[i].toStringAsFixed(1);
      double speed = double.parse(tempSpeed);

      spots.add(FlSpot(i.toDouble(), speed));
      minX = min(minX, i.toDouble());
      maxX = max(maxX, i.toDouble());
      minY = min(minY, speed);
      maxY = max(maxY, speed);
    }

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: myBlueColor,
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: const Color.fromARGB(130, 27, 177, 232),
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
    );
  }

  LineChartData createElevationLineChartData() {
    List<FlSpot> spots = [];

    double maxX = -double.infinity;
    double maxY = -double.infinity;

    List<double> altitudes = widget.routeRecord.routePoints
        .map((location) => location.altitude)
        .toList();

    for (int i = 0; i < altitudes.length; i += 1) {
      String tempAltitude = altitudes[i].toStringAsFixed(1);
      double altitude = double.parse(tempAltitude);

      spots.add(FlSpot(i.toDouble(), altitude));
      maxX = max(maxX, i.toDouble());
      maxY = max(maxY, altitude);
    }

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: myBlueColor,
          barWidth: 2,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: const Color.fromARGB(130, 27, 177, 232),
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
    );
  }

  void setTimelineWidgets() {
    timelineWidgets.add(
      TimelineTile(
        alignment: TimelineAlign.start,
        isFirst: true,
        endChild: Container(
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          child: Text(
            "Started at ${DateFormat('h:mm a').format(widget.routeRecord.startDate)}",
            style: myTextStyleBold.copyWith(fontSize: 18),
          ),
        ),
        indicatorStyle: IndicatorStyle(
          color: myBlueColor,
          width: 35,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          indicator: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.place,
              color: Colors.white,
            ),
          ),
        ),
        afterLineStyle: LineStyle(color: myBlueColor),
      ),
    );

    timelineWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 160,
          child: FlutterMap(
            mapController: map2Controller,
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 15,
              interactiveFlags: InteractiveFlag.none,
              onTap: (tapPosition, point) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullscreenMapScreen(
                      routeRecord: widget.routeRecord,
                    ),
                  ),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
        ),
      ),
    );

    timelineWidgets.add(
      TimelineTile(
        alignment: TimelineAlign.start,
        endChild: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${maxSpeed.toStringAsFixed(1)} km/h",
                style: myTextStyleBold.copyWith(fontSize: 16),
              ),
              const Divider(
                thickness: 1,
                endIndent: 220,
                color: Color.fromARGB(70, 255, 255, 255),
              ),
              Text(
                "Around ${DateFormat('h:mm a').format(maxSpeedTime)} after ${maxSpeedDistance.toStringAsFixed(1)} km",
                style: myTextStyle.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        indicatorStyle: IndicatorStyle(
          color: myBlueColor,
          width: 35,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          indicator: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.rocket,
              color: Colors.white,
            ),
          ),
        ),
        beforeLineStyle: LineStyle(color: myBlueColor),
        afterLineStyle: LineStyle(color: myBlueColor),
      ),
    );
    timelineWidgets.add(
      TimelineTile(
        alignment: TimelineAlign.start,
        endChild: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${maxElevation.toStringAsFixed(1)} m",
                style: myTextStyleBold.copyWith(fontSize: 16),
              ),
              const Divider(
                thickness: 1,
                endIndent: 220,
                color: Color.fromARGB(70, 255, 255, 255),
              ),
              Text(
                "Around ${DateFormat('h:mm a').format(maxElevationTime)} after ${maxElevationDistance.toStringAsFixed(1)} km",
                style: myTextStyle.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        indicatorStyle: IndicatorStyle(
          color: myBlueColor,
          width: 35,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          indicator: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.landscape,
              color: Colors.white,
            ),
          ),
        ),
        beforeLineStyle: LineStyle(color: myBlueColor),
        afterLineStyle: LineStyle(color: myBlueColor),
      ),
    );

    if (maxElevationTime.isBefore(maxSpeedTime)) {
      var temp = timelineWidgets[2];
      timelineWidgets[2] = timelineWidgets[3];
      timelineWidgets[3] = temp;
    }

    timelineWidgets.add(
      TimelineTile(
        alignment: TimelineAlign.start,
        isLast: true,
        endChild: Container(
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          child: Text(
            "Finished at ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.routeRecord.routePoints.last.time.toInt()))}",
            style: myTextStyleBold.copyWith(fontSize: 18),
          ),
        ),
        indicatorStyle: IndicatorStyle(
          color: myBlueColor,
          width: 35,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          indicator: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.flag,
              color: Colors.white,
            ),
          ),
        ),
        beforeLineStyle: LineStyle(color: myBlueColor),
      ),
    );
  }
}
