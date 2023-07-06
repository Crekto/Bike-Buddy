import 'package:bike_buddy/constants.dart';
import 'package:flutter/material.dart';

import '../weather_data.dart';

class HourlyWeather extends StatelessWidget {
  final HourlyWeatherData weather;
  const HourlyWeather({required this.weather, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      width: 95,
      decoration: BoxDecoration(
        color: myGreyColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Text(
          weather.time,
          style: myTextStyle.copyWith(fontSize: 16, color: Colors.grey[300]),
        ),
        const SizedBox(
          height: 12,
        ),
        Image(
          image: AssetImage(weather.icon),
          height: 50,
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          "${weather.current}\u00B0",
          style: myTextStyle.copyWith(fontSize: 16),
        ),
      ]),
    );
  }
}
