import 'package:bike_buddy/screens/bikes/database/entities/route_record.dart';
import 'package:bike_buddy/screens/map/screens/components/route_card.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  late List<RouteRecord> routeRecords;
  List<Widget> routeRecordWidgets = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Routes"),
      ),
      body: FutureBuilder<List<RouteRecord>?>(
        future: readRouteHistory(),
        builder: (context, AsyncSnapshot<List<RouteRecord>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return const Center(child: Text("No routes recorded yet."));
            } else {
              routeRecords = snapshot.data!;
              routeRecordWidgets = listToWidgetList(routeRecords);

              return SingleChildScrollView(
                child: Column(
                  children: routeRecordWidgets,
                ),
              );
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
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

  List<Widget> listToWidgetList(List<RouteRecord> routes) {
    List<Widget> routeRecordWidgets = [];
    for (var route in routes) {
      routeRecordWidgets.add(RouteCard(
        routeRecord: route,
        routeIndex: routes.indexOf(route),
        parentRefresh: refresh,
      ));
    }
    return routeRecordWidgets;
  }

  void refresh() {
    setState(() {});
  }
}
