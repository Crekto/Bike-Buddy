import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CurrentWeatherData {
  final String location;
  final String condition;
  final String description;
  final String day;
  final String icon;
  final int current;
  final int rainChance;
  final double wind;
  final int humidity;

  CurrentWeatherData({
    required this.location,
    required this.condition,
    required this.description,
    required this.day,
    required this.icon,
    required this.current,
    required this.rainChance,
    required this.wind,
    required this.humidity,
  });
}

class HourlyWeatherData {
  final String time;
  final String icon;
  final int current;

  HourlyWeatherData({
    required this.time,
    required this.icon,
    required this.current,
  });
}

class DailyWeatherData {
  final String day;
  final String icon;
  final String condition;
  final int max;
  final int min;

  DailyWeatherData({
    required this.day,
    required this.icon,
    required this.condition,
    required this.max,
    required this.min,
  });
}

final _weekdayNames = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

Future<List?> fetchData(String lat, String lon, String city) async {
  var url =
      "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&units=metric&appid=${dotenv.env['OPENWEATHERMAP_API_KEY']}";
  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    DateTime date = DateTime.now();
    var res = json.decode(response.body);
    var current = res["current"];
    var currentWeather = CurrentWeatherData(
      location: city,
      current: current["temp"].round(),
      condition: current["weather"][0]["main"],
      description: current["weather"][0]["description"],
      day: DateFormat("EEEE, dd MMMM").format(date),
      icon: 'lib/images/weather/${current["weather"][0]["icon"]}.png',
      rainChance: (res["daily"][0]["pop"] * 100).round(),
      wind: current["wind_speed"] * 3.6,
      humidity: current["humidity"].round(),
    );

    // Hourly
    List<HourlyWeatherData> hourlyWeather = [];
    var hourly = res["hourly"];
    for (var i = 0; i < 13; i++) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          hourly[i]["dt"] * 1000,
          isUtc: true);

      String time = DateFormat('h a').format(date.toLocal());
      var temp = HourlyWeatherData(
          time: i == 0 ? "Now" : time,
          icon: 'lib/images/weather/${hourly[i]["weather"][0]["icon"]}.png',
          current: hourly[i]["temp"].round());

      hourlyWeather.add(temp);
    }

    // Daily
    List<DailyWeatherData> dailyWeather = [];
    var daily = res["daily"];
    for (var i = 0; i < 8; i++) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(daily[i]["dt"] * 1000,
          isUtc: true);
      int weekdayNumber = date.weekday;

      var temp = DailyWeatherData(
          day: i == 0 ? "Today" : _weekdayNames[weekdayNumber].toString(),
          icon: 'lib/images/weather/${daily[i]["weather"][0]["icon"]}.png',
          condition: daily[i]["weather"][0]["main"],
          max: daily[i]["temp"]["max"].round(),
          min: daily[i]["temp"]["min"].round());

      dailyWeather.add(temp);
    }

    return [currentWeather, hourlyWeather, dailyWeather];
  }
  return null;
}

class CityData {
  final String city;
  final String country;
  final String region;
  final String lat;
  final String long;

  CityData(
      {required this.city,
      required this.country,
      required this.region,
      required this.lat,
      required this.long});
}

Future<List<CityData>?> fetchCities(String name) async {
  var url =
      "http://api.positionstack.com/v1/forward?access_key=${dotenv.env['GEOCODING_API_KEY']}&query=$name";
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var res = json.decode(response.body);
    res = res["data"];
    if (res.length == 0) return null;
    List<CityData> cities = [];
    for (var city in res) {
      List<Placemark> temp1 =
          await placemarkFromCoordinates(city["latitude"], city["longitude"]);
      var temp2 = CityData(
          city: temp1[0].locality.toString(),
          country: temp1[0].isoCountryCode.toString(),
          region: temp1[0].subAdministrativeArea.toString(),
          lat: city["latitude"].toString(),
          long: city["longitude"].toString());
      cities.add(temp2);
    }
    return cities;
  }

  return null;
}
