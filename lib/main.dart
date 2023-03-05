import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import './pages/caregiver.dart' show Caregiver;
import './pages/patient.dart' show Patient;
import './pages/volunteer.dart' show Volunteer;
import 'package:flutter_blue/flutter_blue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            bodySmall: TextStyle(fontSize: 12.0)),
      ),
      home: MyHomePage(title: "Temp Navigator"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  String _address = "...";
  String _name = "...";

  void initBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        debugPrint('${r.device.name} found! rssi: ${r.rssi}');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              ' display large',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              'display medium',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              'title small',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'body large',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'body medium',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'body small',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Patient()),
                  );
                },
                child: const Text('Patient Page')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Caregiver()),
                  );
                },
                child: const Text('Caregiver Page')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Volunteer()),
                  );
                },
                child: const Text('Volunteer Page')),
            Text(
              'Address: $_address',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Name: $_name',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
