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
import '../main.dart' show HeadHomeApp;

import 'package:headhome/utils/strings.dart';
import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/carereceiverdata.dart';

import '../components/gmaps_widget.dart' show GmapsWidget;
import '../components/stview_widget.dart' show GmapsStView;

/// Patient page (displays when patient logs in).
class Patient extends StatefulWidget {
  const Patient({super.key, required this.carereceiverModel});
  final CarereceiverModel carereceiverModel;

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  /// Whether SOS has been called by the patient.
  bool sosCalled = false;

  /// Variables that control UI logic.
  bool visible = true;
  bool fade = true;
  bool stview = false;

  /// Details of the current logged in patient.
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

  /// For storing edit patient profile form state.
  String tempName = "";
  String tempPhoneNum = "";
  String tempAddress = "";
  String tempRel = "";

  /// Patient current location details.
  LatLng? currentPosition;
  Set<Polyline> polylines = {};

  /// Stores the route back home and corresponding information.
  int routeIndex = 0;
  List<RouteLog> routeLogsModel = [];
  double distanceToNextRouteLog = 0;

  /// Stores the absolute bearing to the next location.
  double bearing = 0.0;

  /// Timer for scheduling locational updates of patient.
  Timer? _lTimer;

  /// Timer for pinging for route information.
  Timer? _rTimer;

  /// Stream to listen out for locational changes.
  StreamSubscription? _positionStream;

  /// For connecting to the HeadHome hardware wearable.
  BluetoothDevice? _device;
  StreamSubscription? _deviceStateSubscription;
  StreamSubscription? _charSubscription;
  BluetoothDeviceState _deviceState = BluetoothDeviceState.disconnected;
  BluetoothCharacteristic? txCharacteristic;
  final Debouncer _debouncer = Debouncer(seconds: 2);

  /// Determine corresponding route arrow to be displayed on the distance banner.
  IconData determineRouteArrow(RouteLog? rl) {
    if (rl == null) return Icons.straight;

    switch (rl.maneuver) {
      case "turn-slight-left":
        return Icons.turn_left;
      case "turn-sharp-left":
        return Icons.turn_sharp_left;
      case "uturn-left":
        return Icons.u_turn_left;
      case "turn-left":
        return Icons.turn_left;
      case "turn-slight-right":
        return Icons.turn_right;
      case "turn-sharp-right":
        return Icons.turn_sharp_right;
      case "uturn-right":
        return Icons.u_turn_right;
      case "turn-right":
        return Icons.turn_right;
      case "ramp-left":
        return Icons.ramp_left;
      case "ramp-right":
        return Icons.turn_right;
      case "merge":
        return Icons.merge;
      case "fork-left":
        return Icons.fork_left;
      case "fork-right":
        return Icons.fork_right;
      case "ferry":
        return Icons.directions_boat;
      case "ferry-train":
        return Icons.directions_ferry;
      case "roundabout-left":
        return Icons.roundabout_left;
      case "roundabout-right":
        return Icons.roundabout_right;
      default:
        return Icons.straight;
    }
  }

  /// Patient Modal with patient details
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
                        ? const NetworkImage(defaultProfilePic) as ImageProvider
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
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
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
      },
    );
  }

  /// Patient Profile edit modal
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
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: profileBytes == null
                        ? const NetworkImage(defaultProfilePic) as ImageProvider
                        : MemoryImage(profileBytes!),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
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
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
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
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
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
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
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
                            borderRadius: BorderRadius.circular(5.0),
                          ),
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
                            borderRadius: BorderRadius.circular(5.0),
                          ),
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      // listen out for whether we've reached the end of current routelog
      if (sosCalled) {
        Location endLocation = routeLogsModel[routeIndex].endLocation;
        double endDistance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          endLocation.lat,
          endLocation.lng,
        );
        double endBearing = Geolocator.bearingBetween(
          position.latitude,
          position.longitude,
          endLocation.lat,
          endLocation.lng,
        );

        double distFromSafe = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.carereceiverModel.safezoneCtr.lat,
          widget.carereceiverModel.safezoneCtr.lng,
        );

        Map<String, dynamic> dataToESP;

        debugPrint('endDistance: $endDistance');
        debugPrint('endBearing:$endBearing');

        // check if user has reached home
        if (distFromSafe > 30) {
          dataToESP = {
            "bearing": endBearing,
            "distance": endDistance.toInt(),
            "alert": 1,
          };
          setState(() {
            distanceToNextRouteLog = endDistance;
            if (endDistance < 10) {
              routeIndex++;
            }
            currentPosition = LatLng(position.latitude, position.longitude);
            bearing = endBearing;
          });
          txCharacteristic?.write(utf8.encode(jsonEncode(dataToESP)));

          // reached home
        } else {
          dataToESP = {
            "bearing": endBearing,
            "distance": endDistance.toInt(),
            "alert": 0,
          };
          setState(() {
            distanceToNextRouteLog = endDistance;
            if (endDistance < 10) {
              routeIndex++;
            }
            currentPosition = LatLng(position.latitude, position.longitude);
            sosCalled = false;
            polylines = {};
            fade = !fade;
            bearing = endBearing;
          });

          const snackBar = SnackBar(
            content: Text("Safely Reached Home!"),
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          ApiService.updateSOS(widget.carereceiverModel.crId, "home");
          txCharacteristic?.write(utf8.encode(jsonEncode(dataToESP)));
        }
      } else {
        setState(() =>
            currentPosition = LatLng(position.latitude, position.longitude));
      }
    });

    _getData();
    _getProfileImg();
    _locationHandler();
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

  // ------- START OF BLUETOOTH METHODS -----

  void _initBluetooth() async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) async {
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

  /// Contact of the caregiver
  void _getContact(cgId) async {
    debugPrint("Getting Contact");
    _cgcontactnumModel = await ApiService.getCgContact(cgId, crId);
    debugPrint(_cgcontactnumModel!.cgContactNum);
    setState(() {
      priContactNo = _cgcontactnumModel!.cgContactNum;
    });
  }

  /// Editing the profile information of the patient
  void _updateData() async {
    var response = await ApiService.updateCarereceiver(crId, nameValue,
        homeAddress, phoneNumberValue, priContactUsername, priContactRel);
    debugPrint(response.body);
  }

  // Load profile image
  void _getProfileImg() async {
    Uint8List? fetchedBytes = await ApiService.getProfileImg(profilePic);
    if (fetchedBytes != null) {
      setState(() {
        profileBytes = fetchedBytes;
      });
    }
  }

  /// Enable direct calling of caregiver by patient
  _callNumber() async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(
        priContactNo.replaceAll(' ', ''));
    if (res!) {
      debugPrint("Working");
    } else {
      debugPrint("Not working");
    }
  }

  /// ------- END OF PROFILE METHODS -------

  /// ------- START OF FUNCTIONAL LOCATION METHODS -------
  /// Updates current position of the patient to the database
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

  /// CAN ALSO USE THIS FUNCTION TO CALL FOR BLUETOOTH BUTTON PRESS BY
  /// manualCALL = true WHEN CALLING THE FUNCTION
  void _locStatusCallHelp(bool manualCall) async {
    String locStatus = await _updateLocStatus(manualCall);
    debugPrint(locStatus);
    if ((locStatus == "warning" || manualCall) && sosCalled == false) {
      debugPrint("CALLING FOR HELP");
      _requestHelp();
      setState(() {
        fade = !fade;
        sosCalled = true;
      });
    }
  }

  /// Timer for location update
  Future<void> _locationHandler() async {
    _locStatusCallHelp(false);
    _lTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      _locStatusCallHelp(false);
    });
  }

  void _requestHelp() async {
    debugPrint(currentPosition!.latitude.toString());
    debugPrint(currentPosition!.longitude.toString());
    var response = await ApiService.requestHelp(
        crId,
        currentPosition!,
        widget.carereceiverModel.safezoneCtr.lat.toString(),
        widget.carereceiverModel.safezoneCtr.lng.toString());
    Map<String, dynamic> res = json.decode(response.body);

    _processRouteResponse(res);

    /// Calling route api every 5 mins
    _routingTimer();
  }

  void _processRouteResponse(Map<String, dynamic> res) {
    /// Converting polyline
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
      if (currentPosition != null && fetchedRouteLogs.isNotEmpty) {
        distanceToNextRouteLog = Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            fetchedRouteLogs[0].endLocation.lat,
            fetchedRouteLogs[0].endLocation.lng);
        bearing = Geolocator.bearingBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            fetchedRouteLogs[0].endLocation.lat,
            fetchedRouteLogs[0].endLocation.lng);
      }
    });
  }

  /// Timer to update route of patient
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

  /// Update routing
  void _routingHelp() async {
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
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const HeadHomeApp(
                  isLocationEnabled: true,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                MaterialSymbols.home_pin,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                "HeadHome",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
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
      body: Stack(
        children: [
          currentPosition != null
              ? (stview
                  ? GmapsStView(
                      latitude: currentPosition!.latitude,
                      longitude: currentPosition!.longitude,
                      bearing: bearing,
                    )
                  : GmapsWidget(
                      polylines: polylines,
                      center: currentPosition!,
                      marker: LatLng(
                        widget.carereceiverModel.safezoneCtr.lat,
                        widget.carereceiverModel.safezoneCtr.lng,
                      ),
                    ))
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
                        Icon(
                          MaterialSymbols.home_pin,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                /// Bar with directions to map home
                visible: sosCalled,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            determineRouteArrow(
                                routeIndex >= routeLogsModel.length - 1
                                    ? null
                                    : routeLogsModel[routeIndex + 1]),
                            size: 100,
                          ),
                          SizedBox(
                            width: 300,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${parseHTML(routeIndex >= routeLogsModel.length - 1 ? "Continue to destination" : routeLogsModel[routeIndex + 1].htmlInstructions)}\n",
                                    ),
                                    TextSpan(
                                        text: routeIndex >=
                                                routeLogsModel.length - 1
                                            ? "For "
                                            : routeLogsModel[routeIndex + 1]
                                                        .maneuver ==
                                                    "straight"
                                                ? "For "
                                                : "In "),
                                    TextSpan(
                                      text:
                                          '${distanceToNextRouteLog.toInt().toString()}m',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  stview = !stview;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: stview ? 0.0 : 4.0,
                                side: !stview
                                    ? BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2.0)
                                    : BorderSide.none,
                              ),
                              child: Container(
                                width: 30.0,
                                height: 60.0,
                                alignment: Alignment.center,
                                child: Icon(Icons.map_outlined,
                                    color: stview
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5)
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  stview = !stview;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: stview ? 4.0 : 0.0,
                                side: stview
                                    ? BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2.0)
                                    : BorderSide.none,
                              ),
                              child: Container(
                                width: 30.0,
                                height: 60.0,
                                alignment: Alignment.center,
                                child: Icon(Icons.apartment_outlined,
                                    color: !stview
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5)
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Align(
            /// Floating red "Navigate Home" button
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _locStatusCallHelp(true);
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: [
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
        ],
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FittedBox(
          child: FloatingActionButton(
            /// Floating action button on Scaffold
            onPressed: () {
              /// code to execute on button press
              debugPrint("Calling caregiver");
              _callNumber();
            },
            backgroundColor:
                Theme.of(context).colorScheme.primary, //icon inside button
            child: const Icon(Icons.phone),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: BottomAppBar(
        /// bottom navigation bar on scaffold
        height: 100,
        color: Theme.of(context).colorScheme.tertiary,
        shape: const CircularNotchedRectangle(), //shape of notch
        notchMargin: 5,

        /// notche margin between floating button and bottom appbar
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
