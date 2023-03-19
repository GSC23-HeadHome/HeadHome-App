import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:headhome/pages/authlogin.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'constants.dart';
import 'package:collection/collection.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeadHome',
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
          ? const MyHomePage()
          : const LocationDisabledPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  BluetoothDevice? _device;
  StreamSubscription? _deviceStateSubscription;
  BluetoothCharacteristic? _targetCharacteristic;
  BluetoothDeviceState _deviceState = BluetoothDeviceState.disconnected;

  void initBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      for (ScanResult r in results) {
        debugPrint('${r.device.name} ${r.device.id} found! rssi: ${r.rssi}');
      }
      _device = results
          .firstWhereOrNull(
              (result) => result.device.name == BluetoothConstants.deviceName)
          ?.device;
      if (_device != null &&
          _deviceState == BluetoothDeviceState.disconnected) {
        debugPrint("Connecting to device...");
        _deviceStateSubscription = _device?.state.listen((s) {
          _deviceState = s;
        });
        await _device!.connect();
        List<BluetoothService> services = await _device!.discoverServices();
        BluetoothService targetService = services.firstWhere((service) =>
            service.uuid.toString() == BluetoothConstants.serviceUUID);
        List<BluetoothCharacteristic> characteristics =
            targetService.characteristics;
        _targetCharacteristic = characteristics.firstWhere((characteristic) =>
            characteristic.uuid.toString() ==
            BluetoothConstants.characteristicUUID);

        if (_targetCharacteristic != null) {
          List<int> receivedData = await _targetCharacteristic!.read();
          debugPrint(String.fromCharCodes(receivedData));
          await _targetCharacteristic!
              .write(utf8.encode("Hello from flutter!"));
        }
      }
    });

// Stop scanning
    flutterBlue.stopScan();
  }

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
    _device?.disconnect();
    _deviceStateSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return const AuthLogin();
  }
}
