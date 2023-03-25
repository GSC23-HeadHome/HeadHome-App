import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:headhome/api/models/volunteerdata.dart';
import 'package:headhome/api/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../api/models/carereceiverdata.dart';
import '../main.dart' show MyApp;
import './volunteerPatient.dart' show PatientPage;
import '../components/profileDialog.dart' show ProfileOverlay;
import '../components/settingsDialog.dart' show SettingsOverlay;
import '../components/gmapsWidget.dart' show GmapsWidget;

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

  final Stream<QuerySnapshot> _soslogStream =
      FirebaseFirestore.instance.collection('sos_log').snapshots();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    Position fetchedPosition = await Geolocator.getCurrentPosition();
    debugPrint("FetchedLocationData: $fetchedPosition");
    setState(() {
      _currentPosition = fetchedPosition;
    });
  }

  Future<String> _updateVolunteerInfo(
      String vId, String _name, String _contact, String _password) async {
    setState(() {
      nameValue = _name;
      contactNum = _contact;
      password = _password;
    });
    //send put request to update caregiver num
    var response = await ApiService.updateVolunteer(contactNum, vId);
    print(response.message);
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  height: 200,
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
                          children: snapshot.data!.docs.map(
                            (document) {
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
                                      : _currentPosition!.longitude);
                              return PatientDetails(
                                distance: distance,
                                sosLogModel: data,
                                volunteerModel: widget.volunteerModel,
                              );
                            },
                          ).toList(),
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
        shape: CircularNotchedRectangle(), //shape of notch
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
              Expanded(
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
  String imageUrl = "https://picsum.photos/id/237/200/300";

  void fetchPatient() async {
    CarereceiverModel? fetchedModel =
        await ApiService.getCarereceiver(widget.sosLogModel["cr_id"]);

    if (fetchedModel != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("ProfileImg/${fetchedModel.profilePic}");
      final String url = await ref.getDownloadURL();
      setState(() {
        _carereceiverModel = fetchedModel;
        imageUrl = url;
      });
    } else {
      setState(() {
        _carereceiverModel = fetchedModel;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatient();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8E3E4),
            borderRadius: BorderRadius.all(Radius.circular(6)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 6,
                offset: Offset(0, 5), // changes position of shadow
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
                      backgroundImage: NetworkImage(imageUrl),
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
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFF263238),
                                fontWeight: FontWeight.w600),
                          ),
                        ])),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                      child: Text("${widget.distance.round()}m away",
                          style: TextStyle(fontSize: 12.0)),
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
                                  imageUrl: imageUrl)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 45),
                        backgroundColor: Theme.of(context).colorScheme.error),
                    child: Text(
                      'Locate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

