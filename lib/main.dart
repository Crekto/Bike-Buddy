import 'dart:async';

import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/firebase_options.dart';
import 'package:bike_buddy/homepage.dart';
import 'package:bike_buddy/screens/auth/auth_screen.dart';
import 'package:bike_buddy/screens/no_internet_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:timezone/data/latest.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notifications/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initNotification();
  initializeTimeZones();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription internetSubscription;
  bool isDeviceConnected = false;
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();

    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) async {
      isDeviceConnected = await hasInternetConnection();
      if (!isDeviceConnected && mounted) {
        Navigator.push(navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) => const NoInternetScreen()));
      }
    });
  }

  Future<bool> hasInternetConnection() async {
    try {
      final response = await head(Uri.parse("https://www.google.com"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: messengerKey,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: myGreyColor,
          ),
          scaffoldBackgroundColor: myBackgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        home: Scaffold(
          body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomePage();
              } else {
                return const AuthScreen();
              }
            },
          ),
        ));
  }
}
