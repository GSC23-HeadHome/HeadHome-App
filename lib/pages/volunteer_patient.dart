import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/caregiverdata.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/soslogdata.dart';
import 'package:headhome/api/models/travellogdata.dart';
import 'package:headhome/api/models/volunteerdata.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/gmaps_widget.dart' show GmapsWidget;
import 'package:headhome/constants.dart';

/// Volunteers will be redirected here upon clicking on patient on the VolunteerPage.
class PatientPage extends StatefulWidget {
  const PatientPage(
      {super.key,
      required this.carereceiverModel,
      required this.profileBytes,
      required this.sosLogModel,
      required this.volunteerModel});
  final CarereceiverModel carereceiverModel;
  final Uint8List? profileBytes;
  final Map<String, dynamic> sosLogModel;
  final VolunteerModel volunteerModel;

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  /// Stores primary caregiver number of patient.
  String _priContactName = "-";

  /// Stores primary contact number of patient.
  String _priContactNo = "-";

  /// Stores current location of patient.
  late LatLng _currentLocation = const LatLng(0, 0);

  /// Timer for scheduling locational updates of patient.
  Timer? _lTimer;

  /// Stores authentication status for current volunteer,
  /// on whether he/she is allowed to guide the patient home and view the patient's
  /// address information.
  bool _authenticated = false;

  /// Retrieves the caregiver number for the patient, number is stored in [_priContactNo].
  void fetchCgNumber() async {
    final Cgcontactnum? fetchedContactNo = await ApiService.getCgContact(
        widget.carereceiverModel.careGiver[0].id,
        widget.carereceiverModel.crId);
    if (fetchedContactNo != null) {
      setState(() {
        _priContactNo = fetchedContactNo.cgContactNum;
      });
    }
  }

  /// Retrieves the caregiver name for the patient, name is stored in [_priContactName].
  void fetchCgName() async {
    final CaregiverModel? caregiverModel =
        await ApiService.getCaregiver(widget.carereceiverModel.careGiver[0].id);
    if (caregiverModel != null) {
      setState(() {
        _priContactName = caregiverModel.name;
      });
    }
  }

  /// Redirects volunteer to patient location on Google Maps.
  void openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  /// Call travel log API and retrieve current location of patient, location is stored in [_currentLocation].
  void getPatientLocation() async {
    final TravelLogModel? travelLogModel =
        await ApiService.getTravelLog(widget.carereceiverModel.crId);
    if (travelLogModel != null) {
      setState(() {
        _currentLocation = LatLng(travelLogModel.currentLocation.lat,
            travelLogModel.currentLocation.lng);
      });
      debugPrint("currentLocation updated");
    }
  }

  /// Schedule travel log API every 5 min to retrieve current location of patient.
  void updateLocation() {
    debugPrint("timer activated");
    _lTimer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      getPatientLocation();
    });
  }

  /// Determines whether volunteer is authenticated to guide the patient home.
  void initialiseAuthenticated() {
    if (widget.sosLogModel["status"] == "guided") {
      setState(() {
        _authenticated = true;
      });
    }
  }

  /// Update current status on whether volunteer is authenticated to guide the patient home.
  void updateAuthenticated(bool newAuthenticated) {
    setState(() {
      _authenticated = newAuthenticated;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCgName();
    fetchCgNumber();
    getPatientLocation();
    updateLocation();
    initialiseAuthenticated();
  }

  @override
  void dispose() {
    super.dispose();
    _lTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    LatLng homeLocation = LatLng(widget.carereceiverModel.safezoneCtr.lat,
        widget.carereceiverModel.safezoneCtr.lng);
    debugPrint(homeLocation.toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: Text(
                "HeadHome",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Scrollbar(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                      child: Column(
                        children: [
                          Text(
                            widget.carereceiverModel.name,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: widget.profileBytes == null
                          ? const NetworkImage(defaultProfilePic)
                              as ImageProvider
                          : MemoryImage(widget.profileBytes!),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: Icon(
                              Icons.crisis_alert_sharp,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          Text(
                            "Out of Safe Zone",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        ],
                      ),
                    ),
                    _authenticated
                        ? FindHome(
                            priContactName: _priContactName,
                            priContactNo: _priContactNo,
                            homeLocation: homeLocation,
                            openMap: openMap,
                          )
                        : FindPatient(
                            priContactName: _priContactName,
                            priContactNo: _priContactNo,
                            sosLogModel: widget.sosLogModel,
                            volunteerModel: widget.volunteerModel,
                            updateAuthenticated: updateAuthenticated,
                            patientLocation: _currentLocation,
                            openMap: openMap,
                          ),
                  ],
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
              heroTag: 'VolunteerPatientFAB',
              //Floating action button on Scaffold
              onPressed: () async {
                //code to execute on button press
                await FlutterPhoneDirectCaller.callNumber(
                    widget.carereceiverModel.contactNum.replaceAll(' ', ''));
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.call), //icon inside button
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        height: 80,
        color: Theme.of(context).colorScheme.tertiary,
        shape: const CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
      ),
    );
  }
}

/// Patient page that displays when the patient is still unguided, and hence volunteer is still
/// unauthenticated to guide the patient home.
class FindPatient extends StatefulWidget {
  const FindPatient({
    super.key,
    required this.priContactName,
    required this.priContactNo,
    required this.sosLogModel,
    required this.volunteerModel,
    required this.updateAuthenticated,
    required this.patientLocation,
    required this.openMap,
  });
  final String priContactName;
  final String priContactNo;
  final Map<String, dynamic> sosLogModel;
  final VolunteerModel volunteerModel;
  final void Function(bool) updateAuthenticated;
  final LatLng patientLocation;
  final void Function(double, double) openMap;

  @override
  State<FindPatient> createState() => FindPatientState();
}

class FindPatientState extends State<FindPatient> {
  final authIdController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    authIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double lat = widget.patientLocation.latitude;
    double lng = widget.patientLocation.longitude;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  children: [
                    Text(
                      "Enter Patient's Authentication ID",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              TextField(
                controller: authIdController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.send_outlined,
                    ),
                    onPressed: () async {
                      debugPrint(widget.sosLogModel["sos_id"]);
                      debugPrint(authIdController.text);
                      debugPrint(widget.volunteerModel.vId);
                      AcceptSOSResponse? response = await ApiService.acceptSOS(
                          widget.sosLogModel["sos_id"],
                          authIdController.text,
                          widget.volunteerModel.vId);
                      debugPrint("$response");
                      if (response != null) {
                        widget.updateAuthenticated(true);
                        debugPrint("updateAuthenticated called");
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              )
            ],
          ),
        ),

        // Google Map widget.
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text("Patient's Location",
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: widget.patientLocation != const LatLng(0, 0)
                        ? GmapsWidget(
                            center: widget.patientLocation,
                            marker: widget.patientLocation,
                          )
                        : Container(),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'MapsVolunteerPatientFAB',
                      onPressed: () {
                        widget.openMap(lat, lng);
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(Icons.navigation),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// Information on patient's caregiver.
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  children: [
                    Text(
                      "Caregiver Information",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 6,
                        offset:
                            const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6, // 60%
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                              child: Wrap(
                                children: [
                                  Text(
                                    widget.priContactName,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFF263238),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                              child: Text(
                                widget.priContactNo,
                                style: const TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4, // 40%
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                          child: ElevatedButton(
                            onPressed: () async {
                              //send alert
                              if (widget.priContactNo != "-") {
                                await FlutterPhoneDirectCaller.callNumber(
                                    widget.priContactNo.replaceAll(' ', ''));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 45),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                            child: const Text(
                              'Contact',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Patient page that displays when the patient is guided by current volunteer,
/// and hence volunteer is authenticated to guide the patient home.
class FindHome extends StatelessWidget {
  const FindHome({
    super.key,
    required this.priContactName,
    required this.priContactNo,
    required this.homeLocation,
    required this.openMap,
  });
  final String priContactName;
  final String priContactNo;
  final LatLng homeLocation;
  final void Function(double, double) openMap;

  @override
  Widget build(BuildContext context) {
    double lat = homeLocation.latitude;
    double lng = homeLocation.longitude;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Google Map widget.
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  "Home Location",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: GmapsWidget(
                      center: homeLocation,
                      marker: homeLocation,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'MapsVolunteerHomeFAB',
                      onPressed: () {
                        openMap(lat, lng);
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(Icons.navigation),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //safe zone
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  children: [
                    Text(
                      "Caregiver Information",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 6,
                        offset:
                            const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6, // 60%
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                              child: Wrap(
                                children: [
                                  Text(
                                    priContactName,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFF263238),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                              child: Text(
                                priContactNo,
                                style: const TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4, // 40%
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (priContactNo != "-") {
                                await FlutterPhoneDirectCaller.callNumber(
                                    priContactNo.replaceAll(' ', ''));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 45),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            child: const Text(
                              'Contact',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
