import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:headhome/api/models/volunteerdata.dart';
import 'package:headhome/constants.dart';
import 'package:headhome/api/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api/models/carereceiverdata.dart';
import '../main.dart' show MyApp;
import 'volunteer_patient.dart' show PatientPage;
import '../components/profile_dialog.dart' show ProfileOverlay;
import '../components/settings_dialog.dart' show SettingsOverlay;
import '../components/gmaps_widget.dart' show GmapsWidget;

final FirebaseFirestore db = FirebaseFirestore.instance;
final Reference ref = FirebaseStorage.instance.ref();

class Volunteer extends StatefulWidget {
  const Volunteer({super.key, required this.volunteerModel});
  final VolunteerModel volunteerModel;

  @override
  State<Volunteer> createState() => _VolunteerState();
}

class _VolunteerState extends State<Volunteer> {
  late String vId = widget.volunteerModel.vId;
  late String nameValue = widget.volunteerModel.name;
  late String contactNum = widget.volunteerModel.contactNum;
  late String password = "";
  Position? _currentPosition;
  LatLng? currentPosition;
  Set<String> polylines = {};

  final Stream<QuerySnapshot> _soslogStream =
      FirebaseFirestore.instance.collection('sos_log').snapshots();

  @override
  void initState() {
    super.initState();
    _getData();
    debugPrint(currentPosition.toString());
  }

  void _getData() async {
    Position fetchedPosition = await Geolocator.getCurrentPosition();
    debugPrint(fetchedPosition.toString());
    debugPrint("FetchedLocationData: $fetchedPosition");
    setState(() {
      _currentPosition = fetchedPosition;
      currentPosition =
          LatLng(fetchedPosition.latitude, fetchedPosition.longitude);
    });
    debugPrint(currentPosition.toString());
  }

  Future<String> _updateVolunteerInfo(
      String vId, String name, String contact, String password) async {
    setState(() {
      nameValue = name;
      contactNum = contact;
      password = password;
    });
    //send put request to update caregiver num
    var response = await ApiService.updateVolunteer(contactNum, vId);
    debugPrint(response.message);
    return response.message;
    //get all careReceiver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          // leading: BackButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   color: Theme.of(context).colorScheme.primary,
          // ),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const MyApp(
                          isLocationEnabled: true,
                        )),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(MaterialSymbols.home_pin,
                    color: Theme.of(context).colorScheme.primary),
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
          )),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                child: Column(
                  children: [
                    const Text("Welcome back,",
                        style: TextStyle(
                            fontSize: 18.0, color: Color(0xFF263238))),
                    Text(nameValue,
                        style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
              //google map widget
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: SizedBox(
                  height: 200,
                  child: currentPosition == null
                      ? Container()
                      : GmapsWidget(
                          center: currentPosition!,
                        ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Text("Patients Near You",
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    const Text(
                      "Help locate these patients and bring them home to their worried caregivers.",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF263238),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              //patients near you
              Expanded(
                child: Scrollbar(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _soslogStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Something went wrong");
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("Loading...");
                        }

                        return ListView(
                          scrollDirection:
                              Axis.vertical, // set the direction of scrolling
                          children: snapshot.data!.docs
                              .map((document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                double distance = Geolocator.distanceBetween(
                                  data["start_location"]["lat"],
                                  data["start_location"]["lng"],
                                  _currentPosition == null
                                      ? data["start_location"]["lat"]
                                      : _currentPosition!.latitude,
                                  _currentPosition == null
                                      ? data["start_location"]["lng"]
                                      : _currentPosition!.longitude,
                                );
                                return {
                                  'distance': distance,
                                  'status': data["status"],
                                  'vname': data["volunteer"],
                                  'data': data,
                                };
                              })
                              .where((item) =>
                                  item['distance'] < 500 &&
                                  (item['status'] as String == "lost" ||
                                      (item['status'] as String == "guided" &&
                                          item['vname'] as String ==
                                              widget.volunteerModel.name)))
                              .map((item) => PatientDetails(
                                    distance: item['distance'] as double,
                                    sosLogModel:
                                        item['data'] as Map<String, dynamic>,
                                    volunteerModel: widget.volunteerModel,
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        height: 80,
        color: Theme.of(context).colorScheme.tertiary,
        shape: const CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            //children inside bottom appbar
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  flex: 5, // 50%
                  child: ProfileOverlay(
                    name: nameValue,
                    phoneNum: contactNum,
                    password: password,
                    role: "Volunteer",
                    updateInfo: _updateVolunteerInfo,
                    id: vId,
                  )),
              const Expanded(
                flex: 5, // 50%
                child: SettingsOverlay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientDetails extends StatefulWidget {
  final num distance;
  final Map<String, dynamic> sosLogModel;
  final VolunteerModel volunteerModel;

  const PatientDetails({
    super.key,
    required this.sosLogModel,
    required this.distance,
    required this.volunteerModel,
  });

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  CarereceiverModel? _carereceiverModel;
  Uint8List? profileBytes;

  void fetchPatient() async {
    CarereceiverModel? fetchedModel =
        await ApiService.getCarereceiver(widget.sosLogModel["cr_id"]);

    debugPrint("fetching patient details");
    if (fetchedModel != null) {
      Uint8List? fetchedBytes =
          await ApiService.getProfileImg(fetchedModel.profilePic);
      setState(() {
        _carereceiverModel = fetchedModel;
        profileBytes = fetchedBytes;
      });
    } else {
      _carereceiverModel = fetchedModel;
    }

    debugPrint("seet patient details");
    debugPrint(_carereceiverModel?.name);
    debugPrint("soslog");
    debugPrint(widget.sosLogModel.toString());
  }

  @override
  void initState() {
    super.initState();
    fetchPatient();
    debugPrint("PATIENT DETAILS WIDGET CALLEDr");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8E3E4),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2, // 60%
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: profileBytes == null
                        ? const NetworkImage(defaultProfilePic) as ImageProvider
                        : MemoryImage(profileBytes!),
                  ),
                )),
            Expanded(
              flex: 4, // 60%
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                      child: Wrap(children: [
                        Text(
                          _carereceiverModel == null
                              ? ""
                              : _carereceiverModel!.name,
                          style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF263238),
                              fontWeight: FontWeight.w600),
                        ),
                      ])),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                    child: Text("${widget.distance.round()}m away",
                        style: const TextStyle(fontSize: 12.0)),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4, // 40%
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                child: ElevatedButton(
                  onPressed: () {
                    if (_carereceiverModel != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientPage(
                              carereceiverModel: _carereceiverModel!,
                              sosLogModel: widget.sosLogModel,
                              volunteerModel: widget.volunteerModel,
                              profileBytes: profileBytes),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 45),
                      backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text(
                    'Locate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
