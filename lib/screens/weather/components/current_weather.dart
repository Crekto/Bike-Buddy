import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/weather/weather_data.dart';
import 'package:flutter/material.dart';

import '../global_city.dart';

class CurrentWeather extends StatefulWidget {
  final Function() getData;
  final CurrentWeatherData weather;
  const CurrentWeather(
      {required this.getData, required this.weather, super.key});

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {
  bool searchBar = false;
  bool dropdownVisible = false;
  bool loadingCity = false;
  var focusNode = FocusNode();
  List<CityData>? _dropdownValues = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (searchBar) {
          setState(() {
            searchBar = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: myBlueColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + 10,
            ),
            Container(
              child: searchBar
                  ? Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Column(
                        children: [
                          TextField(
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: myGreyColor,
                              filled: true,
                              hintText: 'Enter a city',
                              hintStyle: const TextStyle(color: Colors.white),
                            ),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) async {
                              setState(() {
                                dropdownVisible = true;
                                loadingCity = true;
                              });
                              List<CityData>? tempCity =
                                  await fetchCities(value.toLowerCase());

                              if (tempCity == null && context.mounted) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: myGreyColor,
                                        title: const Text("City not found."),
                                        content: const Text(
                                            "Please check the city name."),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text("Ok"))
                                        ],
                                      );
                                    });

                                searchBar = false;
                                return;
                              }
                              setState(() {
                                _dropdownValues = tempCity;
                                loadingCity = false;
                              });

                              //searchBar = false;
                            },
                          ),
                          Visibility(
                            visible: dropdownVisible,
                            child: loadingCity
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: DropdownButtonFormField<CityData>(
                                      decoration: InputDecoration(
                                          fillColor: myGreyColor,
                                          filled: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      dropdownColor: myGreyColor,
                                      hint: const Text(
                                        "Select the city.",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style:
                                          const TextStyle(color: Colors.white),
                                      items: _dropdownValues!
                                          .map((CityData value) {
                                        return DropdownMenuItem<CityData>(
                                          value: value,
                                          child: Text(
                                              "${value.city}, ${value.region}, ${value.country}"),
                                        );
                                      }).toList(),
                                      onChanged: (CityData? newCity) {
                                        cityDisplayName =
                                            "${newCity!.city}, ${newCity.region}, ${newCity.country}";
                                        lat = newCity.lat;
                                        long = newCity.long;
                                        gettingCurrentLocation = false;
                                        widget.getData();

                                        searchBar = false;
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: GestureDetector(
                              onTap: () {
                                searchBar = true;
                                setState(() {});
                                focusNode.requestFocus();
                              },
                              child: Text(
                                widget.weather.location,
                                style: myTextStyleBold,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.5, right: 16),
                            child: GestureDetector(
                                onTap: () {
                                  gettingCurrentLocation = true;

                                  widget.getData();
                                },
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
            ),
            Row(
              children: [
                Image(
                  image: AssetImage(widget.weather.icon),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Column(
                      children: [
                        Text(
                          "${widget.weather.current.toString()}\u00B0",
                          style: myTextStyleBold.copyWith(fontSize: 86),
                        ),
                        Text(
                          widget.weather.condition,
                          style: myTextStyle.copyWith(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.weather.description
                              .split(' ')
                              .map((word) => word.replaceRange(
                                  0, 1, word[0].toUpperCase()))
                              .join(' '),
                          style: myTextStyle.copyWith(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            widget.weather.day,
                            style: myTextStyle.copyWith(
                                fontSize: 18, fontWeight: FontWeight.w200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.thunderstorm,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "${widget.weather.rainChance}%",
                      style: myTextStyle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.air,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "${widget.weather.wind.toStringAsFixed(1)} Km/h",
                      style: myTextStyle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "${widget.weather.humidity}%",
                      style: myTextStyle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
