import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/travellogdata.dart';
import 'package:headhome/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/gmapsWidget.dart' show GmapsWidget;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:headhome/api/api_services.dart';

class PatientDetails extends StatefulWidget {
  const PatientDetails(
      {super.key, required this.carereceiverModel, required this.profileBytes});
  final CarereceiverModel carereceiverModel;
  final Uint8List? profileBytes;

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class MyState extends ChangeNotifier {
  bool alert_sent = false;
  bool get _alert_sent => alert_sent;

  void respondButton(CarereceiverModel model) async {
    debugPrint("state changed");
    debugPrint(alert_sent.toString());
    await ApiService.sendSOS(model.crId);
    await model.getCRSOSLog();
    alert_sent = !alert_sent;
    notifyListeners();
  }

  void initAlertSent(bool sent) {
    alert_sent = sent;
    notifyListeners();
  }
}

class _PatientDetailsState extends State<PatientDetails> {
  final MyState _myState = MyState();
  LatLng? patientLocation;
  Timer? _lTimer;
  String distanceValue = "";

  bool _showAlertButton = false;

  Future<void> _getCRSOSLog() async {
    await widget.carereceiverModel.getCRSOSLog();
    if (widget.carereceiverModel.soslog != null) {
      _myState.initAlertSent(
          widget.carereceiverModel.soslog!.status == "lost" ||
              widget.carereceiverModel.soslog!.status == "guided");
    }
  }

  //redirect to google maps
  void openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  //call travel log and update current location
  void getPatientLocation() async {
    final TravelLogModel? travelLogModel =
        await ApiService.getTravelLog(widget.carereceiverModel.crId);
    if (travelLogModel != null) {
      setState(() {
        patientLocation = LatLng(travelLogModel.currentLocation.lat,
            travelLogModel.currentLocation.lng);
      });
      debugPrint("currentLocation updated");
    }
  }

  //call travel log every 5 min to update current location
  void updateLocation() {
    debugPrint("timer activated");
    _lTimer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      getPatientLocation();
    });
  }

  @override
  void initState() {
    super.initState();
    _getCRSOSLog();
    if (widget.carereceiverModel.travellog != null) {
      _showAlertButton =
          widget.carereceiverModel.travellog!.status == "safezone unsafe" ||
              widget.carereceiverModel.travellog!.status == "warning";
    }
    getPatientLocation();
    updateLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _lTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // double lat = patientLocation!.latitude;
    // double lng = patientLocation!.longitude;
    // var responded;
    // var alertStatus;
    // void toggleAlert (responded) {}

    // if (responded == 0) {
    //   alertStatus = sendAlert();
    // } else {
    //   alertStatus = alertSent(response: responded);
    // }

    return ChangeNotifierProvider(
      create: (_) => _myState,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: BackButton(
            //go back on pressed
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
                    scrollDirection:
                        Axis.vertical, // set the direction of scrolling
                    children: <Widget>[
                      // list of widgets that you want to scroll through
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                        child: Column(
                          children: [
                            Text(widget.carereceiverModel.name,
                                style:
                                    Theme.of(context).textTheme.displayMedium),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: widget.profileBytes == null
                              ? const NetworkImage(defaultProfilePic)
                              : MemoryImage(widget.profileBytes!)
                                  as ImageProvider,
                        ),
                      ),
                      _showAlertButton
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: Icon(
                                      widget.carereceiverModel.travellog !=
                                                  null &&
                                              widget.carereceiverModel
                                                      .travellog!.status ==
                                                  "safezone unsafe"
                                          ? Icons.priority_high
                                          : Icons.crisis_alert_sharp,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  Text(
                                    widget.carereceiverModel.travellog !=
                                                null &&
                                            widget.carereceiverModel.travellog!
                                                    .status ==
                                                "safezone unsafe"
                                        ? "Patient needs help"
                                        : "Out of Safe Zone",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                      _showAlertButton
                          ? sendAlert(model: widget.carereceiverModel)
                          : Container(),
                      // Notes
                      _showAlertButton
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    child: Text("Notes",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                  ),
                                  Text(widget.carereceiverModel.notes,
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xFF263238))),
                                ],
                              ),
                            )
                          : Container(),
                      //google map widget
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text("Current Location",
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                            Stack(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: patientLocation == null
                                      ? Container()
                                      : GmapsWidget(
                                          center: patientLocation!,
                                          marker: patientLocation!,
                                        ),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: FloatingActionButton(
                                    heroTag: 'MapsVolunteerPatientFAB',
                                    onPressed: () {
                                      openMap(patientLocation!.latitude,
                                          patientLocation!.longitude);
                                    },
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
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
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                                child: Row(
                                  children: [
                                    Text("Safe Zone",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    const Icon(Icons.edit)
                                  ],
                                ),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Distance from home',
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                  hintText: 'Enter Distance',
                                  suffixText: 'meters',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    distanceValue = newValue!;
                                  });
                                },
                              ),
                            ]),
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
                //Floating action button on Scaffold
                onPressed: () {
                  //code to execute on bxutton press
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add), //icon inside button
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
      ),
    );
  }
}

class sendAlert extends StatelessWidget {
  const sendAlert({super.key, required this.model});
  final CarereceiverModel model;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyState>(builder: (context, myState, child) {
      if (model.soslog != null) {
        debugPrint("Model: ${model.soslog!.vId}");
      } else {
        debugPrint("Model: null");
      }
      debugPrint("updated child with: ${myState._alert_sent}");
      return myState._alert_sent
          ? Column(
              children: [
                //button
                SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Do nothing as alert cannot be unsent
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor: Colors.grey),
                      child: const Text(
                        'Alert Sent',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                //text below button
                model.soslog != null && model.soslog!.vId != ""
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        child: Text(
                          '1 Volunteer(s) Responded',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
                model.soslog != null && model.soslog!.vId != ""
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 6,
                                offset: const Offset(
                                    0, 5), // changes position of shadow
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
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 0, 20),
                                      child: Wrap(
                                        children: [
                                          Text(
                                            model.soslog == null
                                                ? ""
                                                : model.soslog!.volunteer,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                color: Color(0xFF263238),
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4, // 40%
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 20, 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //do nothing
                                      FlutterPhoneDirectCaller.callNumber(
                                          model.soslog == null
                                              ? ""
                                              : model
                                                  .soslog!.volunteerContactNum);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 45),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
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
                      )
                    : Container(),
              ],
            )
          : Column(
              children: [
                //button
                SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        //send alert
                        myState.respondButton(model);
                        debugPrint("responded");
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor: const Color(0xFFF8E3E4)),
                      child: Text(
                        'Send Alert',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ),
                //text below button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Text(
                    "Navigation for elderly will be activated, and alert will be sent to nearby volunteers.",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
    });
  }
}
