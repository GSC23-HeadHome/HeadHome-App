import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:headhome/pages/authlogin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<bool> locationEnabled() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    debugPrint('Location services are disabled.');
    return false;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      debugPrint('Location permissions are denied');
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    debugPrint(
        'Location permissions are permanently denied, we cannot request permissions.');
    return false;
  }

  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isLocationEnabled = await locationEnabled();
  if (!isLocationEnabled) {
    await Geolocator.openLocationSettings();
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(
    MyApp(
      isLocationEnabled: isLocationEnabled,
    ),
  );
}

class LocationDisabledPage extends StatelessWidget {
  const LocationDisabledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Please Enable Location Services and restart the app!"),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isLocationEnabled});
  final bool? isLocationEnabled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeadHome',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF39619B),
          secondary: const Color(0xFF036F5C),
          tertiary: const Color(0xFFDBE9FD),
          error: const Color(0xFFEC414E),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          //headline 3
          displayLarge: TextStyle(
              fontSize: 34.0,
              color: Color(0xFF263238),
              fontWeight: FontWeight.bold),
          //headline 5
          displayMedium: TextStyle(
              fontSize: 24.0,
              color: Color(0xFF263238),
              fontWeight: FontWeight.w700),
          //subtitle2
          titleSmall: TextStyle(
              fontSize: 18.0,
              color: Color(0xFF263238),
              fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16.0),
          bodyMedium: TextStyle(fontSize: 14.0),
          bodySmall: TextStyle(fontSize: 12.0),
        ),
      ),
      home: isLocationEnabled != null && isLocationEnabled!
          ? const AuthLogin()
          : const LocationDisabledPage(),
    );
  }
}
