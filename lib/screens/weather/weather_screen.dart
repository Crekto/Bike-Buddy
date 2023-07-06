import 'dart:async';

import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/weather/components/current_weather.dart';
import 'package:bike_buddy/screens/weather/components/daily_weather.dart';
import 'package:bike_buddy/screens/weather/components/error_searchbar_weather.dart';
import 'package:bike_buddy/screens/weather/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'components/hourly_weather.dart';
import 'global_city.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Function() myFuture;
  late CurrentWeatherData currentWeather;
  late List<HourlyWeatherData> hourlyWeather;
  List<Widget> hourlyWidgets = [];
  List<Widget> dailyWidgets = [];

  // Geolocator
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  late StreamSubscription<Position> streamSubscription;
  Object? geolocatorError;

  Future<List?> getData() async {
    geolocatorError = null;
    if (gettingCurrentLocation) {
      try {
        await _getCurrentPosition();
      } catch (e) {
        geolocatorError = e;
        return null;
      }
    }
    hourlyWidgets = [];
    dailyWidgets = [];

    return await fetchData(lat, long, cityDisplayName);
  }

  @override
  void initState() {
    super.initState();
    myFuture = getData;
  }

  void reloadData() {
    setState(() {
      myFuture = getData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myBackgroundColor,
      body: FutureBuilder<List<dynamic>?>(
          future: myFuture(),
          builder: (context, AsyncSnapshot<List?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (geolocatorError != null) {
                return ErrorSearchbarWeather(
                    getData: reloadData, error: geolocatorError.toString());
              }

              if (snapshot.data == null) {
                return Center(
                  child: Text(
                    "There was an error in receiving the data, try again later.",
                    style: myTextStyleBold,
                  ),
                );
              }

              for (var data in snapshot.data![1]) {
                hourlyWidgets.add(HourlyWeather(weather: data));
              }

              for (var data in snapshot.data![2]) {
                dailyWidgets.add(DailyWeather(weather: data));
              }

              return Column(children: [
                CurrentWeather(getData: reloadData, weather: snapshot.data![0]),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 5, right: 10),
                      child: Column(
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 24,
                                ),
                                Text(
                                  "HOURLY FORECAST",
                                  style: myTextStyle.copyWith(
                                    fontSize: 18,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Wrap(
                                    spacing: 16,
                                    children: hourlyWidgets,
                                  ),
                                ),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 24,
                                ),
                                Text(
                                  "DAILY FORECAST",
                                  style: myTextStyle.copyWith(
                                    fontSize: 18,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Wrap(
                                    spacing: 16,
                                    children: dailyWidgets,
                                  ),
                                ),
                              ]),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]);
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Receiving the data",
                    style: myTextStyleBold,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          }),
    );
  }

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are not enabled");
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Permissions are denied forever");
    }

    Position? position = await _geolocatorPlatform.getLastKnownPosition();
    position ??= await _geolocatorPlatform.getCurrentPosition();
    List<Placemark> temp1 =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    lat = position.latitude.toString();
    long = position.longitude.toString();

    cityDisplayName =
        "${temp1[0].locality}, ${temp1[0].subAdministrativeArea}, ${temp1[0].isoCountryCode}";
  }
}
