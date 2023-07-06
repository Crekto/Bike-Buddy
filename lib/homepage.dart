import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/bikes/bikes_screen.dart';
import 'package:bike_buddy/screens/map/map_screen.dart';
import 'package:bike_buddy/screens/weather/weather_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Widget _selectedWidget;
  late int _selectedIndex;

  @override
  void initState() {
    _selectedWidget = const BikesScreen();
    _selectedIndex = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: DotNavigationBar(
        margin: const EdgeInsets.only(left: 10, right: 10),
        currentIndex: _selectedIndex,
        dotIndicatorColor: Colors.transparent,
        unselectedItemColor: Colors.blueGrey,
        backgroundColor: myGreyColor,
        marginR: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        boxShadow: const [
          BoxShadow(
              color: Colors.black,
              blurRadius: 1,
              spreadRadius: 1,
              offset: Offset(0, 2))
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              _selectedWidget = const WeatherScreen();
            } else if (index == 1) {
              _selectedWidget = const BikesScreen();
            } else if (index == 2) {
              _selectedWidget = const MapScreen();
            }
          });
        },
        items: [
          DotNavigationBarItem(
            icon: const Icon(Icons.cloud),
            selectedColor: myBlueColor,
          ),
          DotNavigationBarItem(
            icon: const Icon(Icons.two_wheeler),
            selectedColor: myBlueColor,
          ),
          DotNavigationBarItem(
            icon: const Icon(Icons.place),
            selectedColor: myBlueColor,
          ),
        ],
      ),
      body: _selectedWidget,
    );
  }
}
