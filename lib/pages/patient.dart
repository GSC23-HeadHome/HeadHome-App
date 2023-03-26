// import 'dart:convert';
// import 'dart:math';

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:headhome/api/models/routelogdata.dart';
import 'package:headhome/utils/debouncer.dart';
import '../constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:headhome/utils/strings.dart';
import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/carereceiverdata.dart';

import '../components/gmapsWidget.dart' show GmapsWidget;

class Patient extends StatefulWidget {
  const Patient({super.key, required this.carereceiverModel});
  final CarereceiverModel carereceiverModel;

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  bool sosCalled = false;

  // UI
  bool visible = true;
  bool fade = true;

  // Patient Details
  late String crId = widget.carereceiverModel.crId;
  late String nameValue = widget.carereceiverModel.name;
  late String phoneNumberValue = widget.carereceiverModel.contactNum;
  late String authenticationID = widget.carereceiverModel.authId;
  late String priContactUsername = widget.carereceiverModel.careGiver.isEmpty
      ? "aurora.lim@gmail.com"
      : widget.carereceiverModel.careGiver[0].id;
  late String priContactRel = widget.carereceiverModel.careGiver.isEmpty
      ? "friend"
      : widget.carereceiverModel.careGiver[0].relationship;
  late String priContactNo = "-";
  late Cgcontactnum? _cgcontactnumModel = {} as Cgcontactnum?;
  late String homeAddress = widget.carereceiverModel.address;
  late String profilePic = widget.carereceiverModel.profilePic;
  Uint8List? profileBytes;

  // Edit profile
  String tempName = "";
  String tempPhoneNum = "";
  String tempAddress = "";
  String tempRel = "";

  // Location details
  LatLng? currentPosition;
  Set<Polyline> polylines = {};

  int routeIndex = 0;
  List<RouteLog> routeLogsModel = [];
  double distanceToNextRouteLog = 0;

  double bearing = 0.0;
  Timer? _lTimer;
  Timer? _rTimer;
  StreamSubscription? _positionStream;

  BluetoothDevice? _device;
  StreamSubscription? _deviceStateSubscription;
  StreamSubscription? _charSubscription;
  BluetoothDeviceState _deviceState = BluetoothDeviceState.disconnected;
  BluetoothCharacteristic? txCharacteristic;
  final Debouncer _debouncer = Debouncer(seconds: 5);

  void showPatientDetails() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            content: SizedBox(
              height: 700,
              width: 500,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nameValue,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          Text(
                            "patient",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: profileBytes == null
                          ? const NetworkImage(defaultProfilePic)
                              as ImageProvider
                          : MemoryImage(profileBytes!),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Authentication ID:",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          authenticationID,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        child: Text(nameValue),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: phoneNumberValue,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        child: Text(phoneNumberValue),
                      ),
                    ),
                    const SizedBox(
                      height: 130,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showEditProfile();
                      },
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showEditProfile() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            title: Center(
              child: Text(
                "Edit Profile",
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            content: SizedBox(
              height: 700,
              width: 500,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 100,
                      backgroundImage:
                          NetworkImage("https://picsum.photos/id/237/200/300"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: nameValue,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            tempName = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: homeAddress,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            tempAddress = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: phoneNumberValue,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            tempPhoneNum = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Primary Contact Relationship',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: priContactRel,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            tempRel = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          onPressed: () {
                            setState(() {
                              tempName = "";
                              tempPhoneNum = "";
                              tempAddress = "";
                              tempRel = "";
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          onPressed: () {
                            setState(() {
                              nameValue = tempName == "" ? nameValue : tempName;
                              phoneNumberValue = tempPhoneNum == ""
                                  ? phoneNumberValue
                                  : tempPhoneNum;
                              homeAddress =
                                  tempAddress == "" ? homeAddress : tempAddress;
                              priContactRel =
                                  tempRel == "" ? priContactRel : tempRel;
                              tempName = "";
                              tempPhoneNum = "";
                              tempAddress = "";
                              tempRel = "";
                            });
                            _updateData();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      // listen out for whether we've reached the end of current routelog
      if (sosCalled) {
        Location endLocation = routeLogsModel[routeIndex].endLocation;
        double endDistance = Geolocator.distanceBetween(position.latitude,
            position.longitude, endLocation.lat, endLocation.lng);
        double endBearing = Geolocator.bearingBetween(position.latitude,
            position.longitude, endLocation.lat, endLocation.lng);

        Map<String, dynamic> dataToESP = {
          "bearing": endBearing,
          "distance": endDistance.toInt(),
          "alert": 1,
        };
        txCharacteristic?.write(utf8.encode(jsonEncode(dataToESP)));

        setState(() {
          distanceToNextRouteLog = endDistance;
          if (endDistance < 10) {
            routeIndex++;
          }
          currentPosition = LatLng(position.latitude, position.longitude);
        });
      } else {
        setState(() =>
            currentPosition = LatLng(position.latitude, position.longitude));
      }
      print("Streaming: $currentPosition");
    });

    _getData();
    _getProfileImg();
    _locationHandler();
    // _bearingTimer();
    _initBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
    _rTimer?.cancel();
    _lTimer?.cancel();
    _charSubscription?.cancel();
    _deviceStateSubscription?.cancel();
    _positionStream?.cancel();
  }

  // ------- Testing ---------
  // Future<void> _bearingTimer() async {
  //   _lTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
  //     setState(() {
  //       bearing += 10;
  //     });
  //   });
  // }

  // ------- START OF BLUETOOTH METHODS -----

  void _initBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      // for (ScanResult r in results) {
      //   debugPrint('${r.device.name} ${r.device.id} found! rssi: ${r.rssi}');
      // }
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
        txCharacteristic = characteristics.firstWhere((characteristic) =>
            characteristic.uuid.toString() ==
            BluetoothConstants.characteristicUUIDTX);

        BluetoothCharacteristic rxCharacteristic = characteristics.firstWhere(
            (characteristic) =>
                characteristic.uuid.toString() ==
                BluetoothConstants.characteristicUUIDRX);

        rxCharacteristic.setNotifyValue(true);
        _charSubscription = rxCharacteristic.value.listen((event) {
          String data = String.fromCharCodes(event);
          if (data.startsWith("{")) {
            debugPrint("Decoded Data: $data");
            Map<String, dynamic> jsonData = jsonDecode(data);
            if (jsonData["SOS"] == "1") {
              _debouncer.run(() {
                setState(() {
                  fade = !fade;
                  _locStatusCallHelp(true);
                });
              });
            }
          }
        });
        await txCharacteristic?.write(utf8.encode("Hello from flutter!"));
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
  }

  // ------- END OF BLUETOOTH METHODS -------

  // ------- START OF PROFILE METHODS -------
  void _getData() async {
    if (widget.carereceiverModel.careGiver.isNotEmpty) {
      _getContact(widget.carereceiverModel.careGiver[0].id);
    } else {
      debugPrint("No Contact");
    }
  }

  void _getContact(cgId) async {
    debugPrint("Getting Contact");
    _cgcontactnumModel = await ApiService.getCgContact(cgId, crId);
    setState(() {
      priContactNo = _cgcontactnumModel!.cgContactNum;
    });
  }

  void _updateData() async {
    var response = await ApiService.updateCarereceiver(crId, nameValue,
        homeAddress, phoneNumberValue, priContactUsername, priContactRel);
    debugPrint(response.body);
  }

  void _getProfileImg() async {
    Uint8List? fetchedBytes = await ApiService.getProfileImg(profilePic);
    if (fetchedBytes != null) {
      setState(() {
        profileBytes = fetchedBytes;
      });
    }
  }

  _callNumber() async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(
        priContactNo.replaceAll(' ', ''));
    if (res!) {
      debugPrint("Working");
    } else {
      debugPrint("Not working");
    }
  }
  // ------- END OF PROFILE METHODS -------

  // ------- START OF FUNCTIONAL LOCATION METHODS -------
  Future<String> _updateLocStatus(bool manualCall) async {
    if (currentPosition != null) {
      double distFromSafe = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          widget.carereceiverModel.safezoneCtr.lat,
          widget.carereceiverModel.safezoneCtr.lng);
      debugPrint(distFromSafe.toString());
      String status = distFromSafe > widget.carereceiverModel.safezoneRadius
          ? "warning"
          : distFromSafe > 30
              ? manualCall
                  ? "safezone unsafe"
                  : "safezone"
              : "home";
      var response = await ApiService.updateCarereceiverLoc(
          crId, currentPosition!.latitude, currentPosition!.longitude, status);
      debugPrint(response.body);

      return status;
    } else {
      return "home";
    }
  }

  // CAN ALSO USE THIS FUNCTION TO CALL FOR BLUETOOTH BUTTON PRESS BY
  // manualCALL = true WHEN CALLING THE FUNCTION
  void _locStatusCallHelp(bool manualCall) async {
    String locStatus = await _updateLocStatus(manualCall);
    debugPrint(locStatus);
    if ((locStatus == "warning" || manualCall) && sosCalled == false) {
      debugPrint("CALLING FOR HELP");
      _requestHelp();
      setState(() {
        sosCalled = true;
      });
    } else if (locStatus == "home") {
      setState(() {
        sosCalled = false;
      });
    }
  }

  Future<void> _locationHandler() async {
    _locStatusCallHelp(false);
    _lTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      _locStatusCallHelp(false);
    });
  }

  void _requestHelp() async {
    // Position position = await _getCurrentPosition();
    debugPrint(currentPosition!.latitude.toString());
    debugPrint(currentPosition!.longitude.toString());
    var response = await ApiService.requestHelp(
        crId,
        currentPosition!,
        widget.carereceiverModel.safezoneCtr.lat.toString(),
        widget.carereceiverModel.safezoneCtr.lng.toString());
    Map<String, dynamic> res = json.decode(response.body);

    _processRouteResponse(res);
    // Calling route api every 5 mins
    _routingTimer();
  }

  void _processRouteResponse(Map<String, dynamic> res) {
    // Converting polyline
    Set<Polyline> tempPoly = {};
    for (int i = 0; i < res["Route"].length; i++) {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> polylinePointsList =
          polylinePoints.decodePolyline(res["Route"][i]["Polyline"]);
      List<LatLng> latLngList = <LatLng>[];
      for (PointLatLng point in polylinePointsList) {
        latLngList.add(LatLng(point.latitude, point.longitude));
      }
      Polyline polyline = Polyline(
        visible: true,
        polylineId: PolylineId(Random().nextInt(10000).toString()),
        points: latLngList,
        color: Colors.blue,
        width: 5,
      );
      tempPoly.add(polyline);
    }
    List<RouteLog> fetchedRouteLogs = [];
    for (Map<String, dynamic> routeLog in res["Route"]) {
      fetchedRouteLogs.add(RouteLog.fromJson(routeLog));
    }

    setState(() {
      polylines = tempPoly;
      routeLogsModel = fetchedRouteLogs;
      routeIndex = 0;
    });
  }

  Future<void> _routingTimer() async {
    _rTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      debugPrint("Routing");
      if (!sosCalled) {
        debugPrint("End routing");
        timer.cancel();
      } else {
        _routingHelp();
      }
    });
  }

  void _routingHelp() async {
    // Position position = await _getCurrentPosition();
    var response = await ApiService.routingHelp(
        currentPosition!,
        widget.carereceiverModel.safezoneCtr.lat.toString(),
        widget.carereceiverModel.safezoneCtr.lng.toString());
    debugPrint(response.body);
    Map<String, dynamic> res = jsonDecode(response.body);
    _processRouteResponse(res);
  }
  // ------- END OF FUNCTIONAL LOCATION METHODS -------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        leadingWidth: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MaterialSymbols.home_pin,
                color: Theme.of(context).colorScheme.primary),
            Text(
              "HeadHome",
              style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showPatientDetails();
            },
            icon: Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Stack(children: [
        currentPosition != null
            ? GmapsWidget(
                polylines: polylines,
                center: currentPosition!,
                bearing: bearing,
              )
            : Container(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: 1,
                    blurRadius: 15,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
                color: const Color(0xFF9ED5CB),
              ),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(MaterialSymbols.home_pin,
                          color: Theme.of(context).colorScheme.primary),
                      Flexible(
                        child: Text(
                          homeAddress,
                          textScaleFactor: 1.2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: sosCalled,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade600,
                      spreadRadius: 1,
                      blurRadius: 15,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 10),
                          children: [
                            TextSpan(
                              text: parseHTML(
                                  routeIndex >= routeLogsModel.length
                                      ? "Continue to destination"
                                      : routeLogsModel[routeIndex + 1]
                                          .htmlInstructions),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: distanceToNextRouteLog.toInt().toString())
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: Visibility(
            visible: visible,
            maintainAnimation: true,
            maintainState: true,
            child: AnimatedOpacity(
              opacity: fade ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              onEnd: () {
                setState(() {
                  visible = !visible;
                });
              },
              child: ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                      const Size.fromRadius(100)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        side: const BorderSide(color: Colors.red)),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    fade = !fade;
                    _locStatusCallHelp(true);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.home_outlined,
                        size: 100,
                      ),
                      Text(
                        "Navigate Home",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
      floatingActionButton: SizedBox(
          height: 80,
          width: 80,
          child: FittedBox(
            child: FloatingActionButton(
              //Floating action button on Scaffold
              onPressed: () {
                //code to execute on button press
                debugPrint("Calling caregiver");
                _callNumber();
              },
              backgroundColor:
                  Theme.of(context).colorScheme.primary, //icon inside button
              child: const Icon(Icons.phone),
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        height: 100,
        color: Theme.of(context).colorScheme.tertiary,
        shape: const CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priContactRel.toTitleCase(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.right,
                ),
                Text(
                  priContactNo,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigateMap extends StatefulWidget {
  const NavigateMap({super.key});

  @override
  State<NavigateMap> createState() => _NavigateMapState();
}

class _NavigateMapState extends State<NavigateMap> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
