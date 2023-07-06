import "package:flutter/material.dart";

import "../../../constants.dart";
import "../global_city.dart";
import "../weather_data.dart";

class ErrorSearchbarWeather extends StatefulWidget {
  final Function() getData;
  final String error;
  const ErrorSearchbarWeather(
      {required this.getData, required this.error, super.key});

  @override
  State<ErrorSearchbarWeather> createState() => _ErrorSearchbarWeatherState();
}

class _ErrorSearchbarWeatherState extends State<ErrorSearchbarWeather> {
  bool searchBar = false;
  bool dropdownVisible = false;
  bool loadingCity = false;

  var focusNode = FocusNode();
  List<CityData>? _dropdownValues = [];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("${widget.error}, check your settings."),
          ),
          const SizedBox(
            height: 18,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
            child: TextField(
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
                          content: const Text("Please check the city name."),
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
                  dropdownVisible = true;
                  loadingCity = false;
                });

                //searchBar = false;
              },
            ),
          ),
          Visibility(
            visible: dropdownVisible,
            child: loadingCity
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
                    child: DropdownButtonFormField<CityData>(
                      decoration: InputDecoration(
                          fillColor: myGreyColor,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      dropdownColor: myGreyColor,
                      hint: const Text(
                        "Select the city.",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: _dropdownValues!.map((CityData value) {
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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
