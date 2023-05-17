import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:headhome/api/models/caregiverdata.dart';
import 'package:headhome/constants.dart';
import '../main.dart' show MyApp;
import 'package:headhome/pages/caregiver_patient.dart' show PatientDetails;
import '../components/profile_dialog.dart' show ProfileOverlay;
import '../components/settings_dialog.dart' show SettingsOverlay;
import '../components/add_patient.dart' show AddPatientOverlay;
import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Caregiver extends StatefulWidget {
  const Caregiver({super.key, required this.caregiverModel});
  final CaregiverModel caregiverModel;

  @override
  State<Caregiver> createState() => _CaregiverState();
}

class _CaregiverState extends State<Caregiver> {
  // late Cgcontactnum? _cgcontactnumModel = {} as Cgcontactnum?;

  //caregiver details
  late String cgId = widget.caregiverModel.cgId;
  late String nameValue = widget.caregiverModel.name;
  late String contactNum = widget.caregiverModel.contactNum;
  late String password = "69823042";

  late List<CareReceiver> careReceivers = widget.caregiverModel.careReceiver;
  late List<CarereceiverModel> careReceiverDetails = [];
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  StreamSubscription? fcmStream;

  @override
  void initState() {
    super.initState();
    _getCaregiverInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _deregisterNotification();
  }

  void _registerNotification(List<CareReceiver> careReceivers) async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted permission with FCMToken: ${await messaging.getToken()}');
    try {
      for (CareReceiver careReceiver in careReceivers) {
        await messaging.subscribeToTopic(careReceiver.id.split("@")[0]);
      }
    } catch (e) {
      debugPrint("Firebase messaging error: $e");
    }

    fcmStream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && message.notification!.body != null) {
        debugPrint('Message: ${message.notification!.title}');
        debugPrint('Body: ${message.notification!.body}');

        final snackBar = SnackBar(
          content: Text(message.notification?.body ?? '', maxLines: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        String crId = message.notification!.body!.split(" ")[0];
        CarereceiverModel? careReceiver =
            careReceiverDetails.firstWhereOrNull((cr) => cr.crId == crId);
        careReceiver?.getCRTravelLog();
      }
    });

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('User declined or has not accepted permission');
    } else {
      debugPrint("User has accepted push notifications");
    }
  }

  void _deregisterNotification() async {
    fcmStream?.cancel();
    try {
      for (CareReceiver careReceiver in careReceivers) {
        await messaging.unsubscribeFromTopic(careReceiver.id.split("@")[0]);
      }
    } catch (e) {
      debugPrint("Firebase messaging error: $e");
    }
  }

  Future<CarereceiverModel?> _fetchCarereceiverInfo(crId) async {
    CarereceiverModel? carereceiverModel =
        await ApiService.getCarereceiver(crId);
    await carereceiverModel?.getCRTravelLog();
    return carereceiverModel;
  }

  void _getCaregiverInfo() async {
    //get all careReceivers
    List<CarereceiverModel?> fetchedCarereceivers = await Future.wait(
        careReceivers.map((e) => _fetchCarereceiverInfo(e.id)));
    setState(() {
      careReceiverDetails =
          fetchedCarereceivers.whereType<CarereceiverModel>().toList();
    });
    _registerNotification(careReceivers);
  }

  Future<String> _updateCgInfo(
      String cgid, String name, String contact, String password) async {
    //set states of parent widget
    setState(() {
      nameValue = name;
      contactNum = contact;
      password = password;
    });

    //send put request to update caregiver num
    var response = await ApiService.updateCg(contactNum, cgid);
    debugPrint(response.message);
    return response.message;
  }

  Future<String> _addNewPatient(
      String cgId, String crId, String relationship) async {
    var response = await ApiService.addPatient(cgId, crId, relationship);
    debugPrint(response.message);
    return response.message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const MyApp(
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
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
              child: Column(
                children: [
                  const Text("Welcome back,",
                      style:
                          TextStyle(fontSize: 18.0, color: Color(0xFF263238))),
                  Text(nameValue,
                      style: Theme.of(context).textTheme.displayMedium),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: SizedBox(
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize.values,
                    children: [
                      Container(),
                      Text("Select Patient",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center),
                      const Icon(Icons.edit)
                    ],
                  ),
                )),
            Expanded(
              child: ListView.builder(
                  itemCount: careReceiverDetails.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Card(
                      elevation: 0,
                      color: Colors.transparent,
                      surfaceTintColor: Colors.white,
                      child: CaregiverPatients(
                        model: careReceiverDetails[i],
                        name: careReceiverDetails[i].name,
                        note: careReceiverDetails[i].notes,
                        status: careReceiverDetails[i].travellog == null
                            ? "home"
                            : careReceiverDetails[i].travellog!.status,
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FittedBox(
            child: AddPatientOverlay(
          addNewPatient: _addNewPatient,
        )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        height: 80,
        color: Theme.of(context).colorScheme.tertiary,
        shape: const CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Row(
          //children inside bottom appbar
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                flex: 5, // 50%
                // child: IconButton(
                //   icon: Icon(
                //     Icons.person_2_outlined,
                //     color: Theme.of(context).colorScheme.primary,
                //   ),
                //   onPressed: () {},
                // ),
                child: ProfileOverlay(
                  name: nameValue,
                  phoneNum: contactNum,
                  password: password,
                  role: "Caregiver",
                  updateInfo: _updateCgInfo,
                  id: cgId,
                )),
            const Expanded(
              flex: 5, // 50%
              child: SettingsOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}

class CaregiverPatients extends StatefulWidget {
  const CaregiverPatients({
    super.key,
    required this.name,
    required this.note,
    required this.status,
    required this.model,
  });

  final String name;
  final String note;
  final String status;
  final CarereceiverModel model;

  @override
  State<CaregiverPatients> createState() => _CaregiverPatientsState();
}

class _CaregiverPatientsState extends State<CaregiverPatients> {
  // either "warning" OR "safezone" OR "home" OR "safezone unsafe"
  Uint8List? profileBytes;

  void _getProfileImg() async {
    if (widget.model.profilePic != "") {
      Uint8List? fetchedBytes =
          await ApiService.getProfileImg(widget.model.profilePic);
      if (fetchedBytes != null) {
        setState(() {
          profileBytes = fetchedBytes;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfileImg();
  }

  @override
  Widget build(BuildContext context) {
    var statusText = "invalid status";
    var containerColour = Colors.white;
    var statusTextColour = const Color(0xFF263238);

    if (widget.status == "warning") {
      statusText = "Out of Safe Zone";
      containerColour = const Color(0xFFF8E3E4);
      statusTextColour = Theme.of(context).colorScheme.error;
    } else if (widget.status == "safezone unsafe") {
      statusText = "Patient Needs Help";
      containerColour = const Color(0xFFF8E3E4);
      statusTextColour = Theme.of(context).colorScheme.error;
    } else if (widget.status == "safezone") {
      statusText = "Within Safe Zone";
      containerColour = Colors.white;
      statusTextColour = Theme.of(context).colorScheme.primary;
    } else if (widget.status == "home") {
      statusText = "At Home";
      containerColour = Colors.white;
      statusTextColour = Theme.of(context).colorScheme.secondary;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetails(
                    carereceiverModel: widget.model,
                    profileBytes: profileBytes),
              ),
            );
          },
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: containerColour,
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
                  flex: 6, // 60%
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 5),
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                                fontSize: 20.0,
                                color: Color(0xFF263238),
                                fontWeight: FontWeight.w500),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 0, 10),
                          child: Wrap(children: [
                            Text(
                              widget.note,
                              style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF263238),
                                  fontWeight: FontWeight.w400),
                            ),
                          ])),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                        child: Text(statusText,
                            style: TextStyle(
                                fontSize: 12.0, color: statusTextColour)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4, // 40%
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: profileBytes == null
                        ? const NetworkImage(defaultProfilePic) as ImageProvider
                        : MemoryImage(profileBytes!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
