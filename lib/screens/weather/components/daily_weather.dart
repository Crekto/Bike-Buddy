import 'package:bike_buddy/constants.dart';
import 'package:flutter/material.dart';

import '../weather_data.dart';

class DailyWeather extends StatelessWidget {
  final DailyWeatherData weather;
  const DailyWeather({required this.weather, super.key});

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
          weather.day,
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
          height: 6,
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              weather.condition,
              style: myTextStyle.copyWith(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          "${weather.min}\u00B0 - ${weather.max}\u00B0",
          style: myTextStyle.copyWith(fontSize: 16),
        ),
      ]),
    );
  }
}
