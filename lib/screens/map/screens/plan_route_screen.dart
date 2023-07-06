import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/screens/map/screens/utils/directions.dart';
import 'package:bike_buddy/screens/map/screens/utils/directions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanRouteScreen extends StatefulWidget {
  const PlanRouteScreen({super.key});

  @override
  State<PlanRouteScreen> createState() => _PlanRouteScreenState();
}

class _PlanRouteScreenState extends State<PlanRouteScreen> {
  double gasPrice = 0;
  double gasConsumption = 0.0;
  late Future<Position?> myFuture;
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  Object? geolocatorError;
  late CameraPosition initialCameraPosition;
  late GoogleMapController _googleMapController;
  List<Marker> markers = [];
  List<Directions>? info;
  int selectedRoute = 0;

  Future<Position?> getData() async {
    geolocatorError = null;
    try {
      gasPrice = await fetchGasPrice();
      gasConsumption = await fetchConsumption();
      return await _getCurrentPosition();
    } catch (e) {
      geolocatorError = e;
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    myFuture = getData();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position?>(
        future: myFuture,
        builder: (context, AsyncSnapshot<Position?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (geolocatorError != null) {
              return Center(
                  child: Text("$geolocatorError, check your settings."));
            }

            if (snapshot.data == null) {
              return Center(
                child: Text(
                  "There was an error in receiving the data, try again later.",
                  style: myTextStyleBold,
                ),
              );
            }
            var initialPosition = snapshot.data;
            initialCameraPosition = CameraPosition(
                target: LatLng(
                    initialPosition!.latitude, initialPosition.longitude),
                zoom: 14);

            return Scaffold(
              appBar: AppBar(
                title: const Text("Ride Planner"),
                actions: [
                  if (markers.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          markers.clear();
                          info = null;
                        });
                        // _googleMapController.animateCamera(
                        //     CameraUpdate.newCameraPosition(
                        //         initialCameraPosition));
                      },
                      child: const Text(
                        "RESET  ",
                      ),
                    )
                  else
                    TextButton(
                        onPressed: () {
                          addMarker(LatLng(initialPosition.latitude,
                              initialPosition.longitude));
                        },
                        child: const Text(
                          "SET ORIGIN",
                        ))
                ],
              ),
              body: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: initialCameraPosition,
                    onMapCreated: (controller) =>
                        _googleMapController = controller,
                    markers: markers.toSet(),
                    polylines: convertDirectionsListToPolylinesSet(info),
                    onLongPress: addMarker,
                  ),
                  if (info != null)
                    Positioned(
                      top: 10,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                            decoration: BoxDecoration(
                              color: myBlueColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 1),
                                    blurRadius: 6)
                              ],
                            ),
                            child: Text(
                              '${formatDistance(info![selectedRoute].distance)}, ${formatDuration(info![selectedRoute].duration)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: showPriceDialog,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 96, 52, 253),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 2),
                                      blurRadius: 6)
                                ],
                              ),
                              child: Text(
                                '${(gasConsumption / 100 * (info![selectedRoute].distance / 1000) * gasPrice).toStringAsFixed(2)} RON @ $gasConsumption L/100km',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (info != null)
                    Positioned(
                      bottom: 40,
                      child: GestureDetector(
                        onTap: launchGoogleMaps,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: myBlueColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                  blurRadius: 6)
                            ],
                          ),
                          child: const Text(
                            'Launch Navigation',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _googleMapController.animateCamera(info != null
                    ? CameraUpdate.newLatLngBounds(info![0].bounds, 80)
                    : CameraUpdate.newCameraPosition(initialCameraPosition)),
                child: const Icon(Icons.my_location),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Future<double> fetchGasPrice() async {
    final response =
        await http.get(Uri.parse('https://www.peco-online.ro/minime.php'));
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);

      // body > div > div.card-columns > div:nth-child(2) > div.card-body.table-responsive > table > tbody > tr:nth-child(1) > td:nth-child(2)
      var element = document.querySelector("body > div > div.card-columns");
      element = element?.children[1];
      element = element?.querySelector('div.card-body > table');
      element = element?.children[2];
      element = element?.querySelector('tbody > tr');
      element = element?.children[1];
      if (element != null) {
        return double.parse(element.text);
      }
    }

    return 0;
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are not enabled");
    }

    permission = await geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Permissions are denied forever");
    }

    Position? position = await geolocatorPlatform.getCurrentPosition();

    return position;
  }

  Future<void> addMarker(LatLng pos) async {
    if (markers.isEmpty) {
      setState(() {
        markers.add(Marker(
          markerId: MarkerId(markers.length.toString()),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        ));
      });
    } else {
      setState(() {
        selectedRoute = 0;
        for (int i = 1; i < markers.length; i++) {
          markers[i] = markers[i].copyWith(
              iconParam: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueCyan));
        }
        markers.add(Marker(
          markerId: MarkerId(markers.length.toString()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        ));
      });

      final directions =
          await DirectionsRepository().getDirections(markers: markers);

      setState(() {
        info = directions;
      });
    }
  }

  Set<Polyline> convertDirectionsListToPolylinesSet(
      List<Directions>? directionsList) {
    if (directionsList == null) return {};
    Set<Polyline> polylines = {};

    for (int i = 0; i < directionsList.length; i++) {
      Directions directions = directionsList[i];
      Polyline polyline = Polyline(
          consumeTapEvents: true,
          polylineId: PolylineId(i.toString()),
          points: directions.polylinePoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
          color: i == selectedRoute ? Colors.blue : Colors.grey,
          width: 6,
          zIndex: i == selectedRoute ? 1 : 0,
          onTap: () {
            setState(() {
              selectedRoute = i;
            });
          });
      polylines.add(polyline);
    }

    return polylines;
  }

  String formatDistance(int distance) {
    String distanceText = '';
    distanceText = distance / 1000 > 1000
        ? (distance / 1000).toStringAsFixed(0)
        : (distance / 1000).toStringAsFixed(1);
    NumberFormat numberFormat = NumberFormat('#,##0.###', 'en_US');
    distanceText = "${numberFormat.format(double.parse(distanceText))} km";

    return distanceText;
  }

  String formatDuration(int duration) {
    String durationText = '';
    int days = duration ~/ (24 * 3600);
    int hours = (duration % (24 * 3600)) ~/ 3600;
    int minutes = ((duration % (24 * 3600)) % 3600) ~/ 60;
    if (days > 0) {
      durationText += '${days.toString()} ${days == 1 ? 'day' : 'days'} ';
    }
    if (hours > 0) {
      durationText += '${hours.toString()} ${hours == 1 ? 'hour' : 'hours'} ';
    }
    if (minutes > 0) {
      durationText += '${minutes.toString()} ${minutes == 1 ? 'min' : 'mins'} ';
    }

    return durationText;
  }

  Future<double> fetchConsumption() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    double? tempConsumption = prefs.getDouble('gasConsumption');
    if (tempConsumption == null) {
      prefs.setDouble('gasConsumption', 0.0);
      return 0.0;
    } else {
      return tempConsumption;
    }
  }

  void showPriceDialog() {
    final formKey = GlobalKey<FormBuilderState>();
    Dialog dialog = Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0)), //this right here
      child: Container(
        height: 300.0,
        width: 300.0,
        decoration: BoxDecoration(
            color: myBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(14))),
        child: FormBuilder(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Column(
              children: [
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'price',
                  initialValue: gasPrice.toString(),
                  decoration: InputDecoration(
                    labelText: 'Gas Price(RON per L)',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'consumption',
                  initialValue: gasConsumption.toString(),
                  decoration: InputDecoration(
                    labelText: 'Gas Consumption(L/100km)',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      var tempPrice = double.parse(
                          formKey.currentState?.fields['price']!.value);
                      var tempConsumption = double.parse(
                          formKey.currentState?.fields['consumption']!.value);

                      if (gasConsumption != tempConsumption) {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setDouble('gasConsumption', tempConsumption);
                        setState(() {
                          gasConsumption = tempConsumption;
                        });
                      }

                      if (gasPrice != tempPrice) {
                        setState(() {
                          gasPrice = tempPrice;
                        });
                      }
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  void launchGoogleMaps() async {
    String url = 'https://www.google.com/maps/dir/?api=1';
    String origin =
        '${markers[0].position.latitude},${markers[0].position.longitude}';
    String destination =
        '${markers[markers.length - 1].position.latitude},${markers[markers.length - 1].position.longitude}';
    url += '&origin=$origin';
    url += '&destination=$destination';

    if (markers.length > 2) {
      String waypoints = '';
      for (int i = 1; i < markers.length - 1; i++) {
        waypoints +=
            '${markers[i].position.latitude},${markers[i].position.longitude}|';
      }
      waypoints = waypoints.substring(0, waypoints.length - 1);
      url += '&waypoints=$waypoints';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch.';
    }
  }
}
