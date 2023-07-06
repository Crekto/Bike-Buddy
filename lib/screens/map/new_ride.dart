import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/map/screens/routes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart' as geol;
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bikes/database/entities/route_record.dart';

enum RecordState {
  stopped,
  running,
  paused,
}

class NewRideScreen extends StatefulWidget {
  const NewRideScreen({Key? key}) : super(key: key);

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  ReceivePort port = ReceivePort();
  List<LocationDto> routePoints = [];
  bool hasLocationPermissions = false;
  final MapController mapController = MapController();
  late Timer timer;
  RecordState recordingState = RecordState.stopped;
  double speedKmH = 0.0;
  double distance = 0.0;
  int durationSeconds = 0;

  @override
  void initState() {
    initPlatformState();
    updateUi();
    super.initState();

    checkLocationPermissions().then((result) {
      setState(() {
        hasLocationPermissions = result;
      });
    });
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();

    bool serviceRunning = await BackgroundLocator.isServiceRunning();
    List<LocationDto> tempRoutePoints = await readLogFile();
    if (serviceRunning == true) {
      setState(() {
        recordingState = RecordState.running;
      });
    } else if (tempRoutePoints.isNotEmpty) {
      setState(() {
        recordingState = RecordState.paused;
      });
      setTotalDuration();
      setDistance();
    } else {
      setState(() {
        recordingState = RecordState.stopped;
      });
    }
  }

  Future<void> loadRoutePoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString('routePoints');
    if (json != null) {
      final List<dynamic> points = jsonDecode(json);
      setState(() {
        routePoints.clear();
        for (var point in points) {
          routePoints.add(LocationDto.fromJson(point));
        }
      });
    }
  }

  Future<void> saveRoutePoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<dynamic> points =
        routePoints.map((point) => point.toJson()).toList();
    final String json = jsonEncode(points);
    await prefs.setString('routePoints', json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Recording'),
      ),
      body: hasLocationPermissions
          ? Column(
              children: [
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: LatLng(0, 0),
                      zoom: 1,
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
                            points: routePoints
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
                const SizedBox(
                  height: 60,
                ),
                durationSeconds <= 0 && recordingState == RecordState.running
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    distance.toStringAsFixed(1),
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 32),
                                  ),
                                  Text(
                                    "KM",
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    formatDuration(durationSeconds),
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 32),
                                  ),
                                  Text(
                                    " ",
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    speedKmH.toStringAsFixed(1),
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 32),
                                  ),
                                  Text(
                                    "KM/H",
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 28,
                          ),
                          if (recordingState == RecordState.stopped)
                            GestureDetector(
                              onTap: _startTimer,
                              child: ClipRect(
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: myBlueColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'START',
                                      style: myTextStyleBold.copyWith(
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (recordingState == RecordState.running)
                            GestureDetector(
                              onTap: _pauseTimer,
                              child: ClipRect(
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: myBlueColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'PAUSE',
                                      style: myTextStyleBold.copyWith(
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (recordingState == RecordState.paused)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _resumeTimer,
                                  child: ClipRect(
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'RESUME',
                                          style: myTextStyleBold.copyWith(
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _finishTimer,
                                  child: ClipRect(
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: myBlueColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'FINISH',
                                          style: myTextStyleBold.copyWith(
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
              ],
            )
          : const Center(
              child: Text('Nu s-au acordat permisiunile de locație.'),
            ),
    );
  }

  Future<void> startRecording() async {
    BackgroundLocator.registerLocationUpdate(
      callback,
      initCallback: null,
      disposeCallback: null,
      autoStop: false,
      iosSettings: const IOSSettings(
          accuracy: LocationAccuracy.BALANCED, distanceFilter: 0),
      androidSettings: const AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 1,
        distanceFilter: 0,
        wakeLockTime: 360,
        androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Recording Route',
            notificationMsg: 'Recording route in background',
            notificationIcon: '',
            notificationIconColor: Colors.grey,
            notificationTapCallback: null),
      ),
    );

    if (context.mounted) {
      setState(() {
        recordingState = RecordState.running;
      });
    }
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    final SendPort? send = IsolateNameServer.lookupPortByName("LocatorIsolate");
    send?.send(locationDto.toJson());
    writeToLogFile(locationDto);
  }

  Future<void> stopRecording() async {
    //BackgroundLocator.unRegisterLocationUpdate();

    List<LocationDto> tempPoints = await readLogFile();
    setState(() {
      routePoints = tempPoints;
    });

    if (routePoints.isNotEmpty) {
      double minLat = routePoints[0].latitude;
      double maxLat = routePoints[0].latitude;
      double minLng = routePoints[0].longitude;
      double maxLng = routePoints[0].longitude;

      for (var point in routePoints) {
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

  static Future<void> writeToLogFile(LocationDto location) async {
    final file = await _getTempLogFile();
    final existingData = await file.readAsString();

    List<dynamic> jsonData;
    if (existingData.isNotEmpty) {
      try {
        jsonData = jsonDecode(existingData);
      } catch (e) {
        debugPrint('Eroare la decodarea JSON: $e');
        jsonData = [];
      }
    } else {
      jsonData = [];
    }
    jsonData.add(location.toJson());

    await file.writeAsString(jsonEncode(jsonData));
  }

  static Future<List<LocationDto>> readLogFile() async {
    final file = await _getTempLogFile();
    final jsonData = await file.readAsString();

    if (jsonData.isEmpty) {
      return [];
    }

    List<dynamic> decodedData;
    try {
      decodedData = jsonDecode(jsonData);
    } catch (e) {
      debugPrint('Eroare la decodarea JSON: $e');
      return [];
    }

    final List<LocationDto> locationList =
        decodedData.map((json) => LocationDto.fromJson(json)).toList();

    return locationList;
  }

  static Future<File> _getTempLogFile() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/log.txt');
    if (!await file.exists()) {
      await file.writeAsString('');
    }
    return file;
  }

  static Future<void> clearLogFile() async {
    final file = await _getTempLogFile();
    await file.writeAsString('');
  }

  Future<bool> checkLocationPermissions() async {
    geol.LocationPermission permission;
    final geol.GeolocatorPlatform geolocatorPlatform =
        geol.GeolocatorPlatform.instance;
    hasLocationPermissions =
        await geolocatorPlatform.isLocationServiceEnabled();
    if (!hasLocationPermissions) {
      return Future.error("Location services are not enabled");
    }

    permission = await geolocatorPlatform.checkPermission();
    if (permission == geol.LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == geol.LocationPermission.denied) {
        return Future.error("Permissions are denied");
      }
    }

    if (permission == geol.LocationPermission.deniedForever) {
      return Future.error("Permissions are denied forever");
    }
    return true;
  }

  //////// Update UI Distance, Timer, Speed

  void updateUi() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (recordingState == RecordState.running && mounted) {
        setTotalDuration();
        setSpeedKmH();
        setDistance();
        setRoutePoints();
      }
    });
  }

  void stopSpeedDistance() {
    timer.cancel();
  }

  Future<void> setSpeedKmH() async {
    List<LocationDto> tempPoints = await readLogFile();
    if (tempPoints.isNotEmpty) {
      setState(() {
        speedKmH = tempPoints.last.speed * 3.6;
      });
    }
  }

  Future<void> setDistance() async {
    double totalDistance = 0;
    List<LocationDto> locations = await readLogFile();

    for (int i = 0; i < locations.length - 1; i++) {
      LocationDto currentLocation = locations[i];
      LocationDto nextLocation = locations[i + 1];

      double lat1 = currentLocation.latitude;
      double lon1 = currentLocation.longitude;
      double lat2 = nextLocation.latitude;
      double lon2 = nextLocation.longitude;

      double distance = calculateDistanceBetweenPoints(lat1, lon1, lat2, lon2);
      totalDistance += distance;
    }

    setState(() {
      distance = totalDistance;
    });
  }

  double calculateDistanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;

    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(lat1)) *
            cos(toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  double toRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> setTotalDuration() async {
    List<LocationDto> locations = await readLogFile();

    setState(() {
      durationSeconds = locations.length;
    });
  }

  Future<void> setRoutePoints() async {
    List<LocationDto> locations = await readLogFile();
    if (locations.isNotEmpty) {
      setState(() {
        routePoints = locations;
        mapController.move(
            LatLng(routePoints.last.latitude, routePoints.last.longitude), 17);
      });
    }
  }

  String formatDuration(int durationInSeconds) {
    int hours = durationInSeconds ~/ 3600;
    int minutes = (durationInSeconds ~/ 60) % 60;
    int seconds = durationInSeconds % 60;

    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = seconds.toString().padLeft(2, '0');

    return '${hours > 0 ? "$hours:" : ""}$minutesString:$secondsString';
  }

  ////////// Butoane Start - Pause - Resume - Finish
  void _startTimer() {
    setState(() {
      recordingState = RecordState.running;
    });
    routePoints.clear();
    clearLogFile();
    startRecording();
  }

  void _pauseTimer() {
    setState(() {
      recordingState = RecordState.paused;
    });
    BackgroundLocator.unRegisterLocationUpdate();
  }

  void _resumeTimer() {
    setState(() {
      recordingState = RecordState.running;
    });
    startRecording();
  }

  void _finishTimer() {
    stopRecording();
    showAlertDialog();
  }

  showAlertDialog() {
    Widget deleteButton = TextButton(
      child: const Text(
        "Abort",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        routePoints.clear();
        clearLogFile();
        setState(() {
          durationSeconds = 0;
          distance = 0;
          speedKmH = 0;
          recordingState = RecordState.stopped;
        });
        Navigator.pop(context);
      },
    );
    Widget saveButton = TextButton(
      child: Text(
        "Save",
        style: TextStyle(color: myBlueColor),
      ),
      onPressed: () async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ));
        final routeDoc = FirebaseFirestore.instance
            .collection("users")
            .doc("${FirebaseAuth.instance.currentUser?.uid}-route");

        List<RouteRecord>? routeHistory = await readRouteHistory();

        if (routeHistory == null) {
          routeHistory = [
            RouteRecord(
              routePoints,
              DateTime.fromMillisecondsSinceEpoch(
                  routePoints.first.time.toInt()),
            )
          ];
          routeDoc.set({
            "routeHistory":
                routeHistory.map((record) => record.toJson()).toList()
          });
        } else {
          routeHistory.insert(
              0,
              RouteRecord(
                routePoints,
                DateTime.fromMillisecondsSinceEpoch(
                    routePoints.first.time.toInt()),
              ));
          routeDoc.update({
            "routeHistory":
                routeHistory.map((record) => record.toJson()).toList()
          });
        }

        routePoints.clear();
        clearLogFile();
        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RoutesScreen()));
        }
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: myGreyColor,
      title: const Text("Save current route?"),
      content:
          const Text("Aborting will result in a lose of the current record."),
      actions: [
        deleteButton,
        saveButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
}
