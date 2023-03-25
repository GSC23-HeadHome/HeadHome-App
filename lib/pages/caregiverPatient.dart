import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/constants.dart';
import 'package:provider/provider.dart';

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

  void respondButton(CarereceiverModel model) {
    alert_sent = !alert_sent;
    ApiService.sendSOS(model.crId);
    print("state changed");
    print(alert_sent);
    notifyListeners();
  }
}

class _PatientDetailsState extends State<PatientDetails> {
  final MyState _myState = MyState();
  String distanceValue = "";

  bool _showAlertButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.carereceiverModel.travellog != null) {
      _showAlertButton =
          widget.carereceiverModel.travellog!.status == "safezone unsafe" ||
              widget.carereceiverModel.travellog!.status == "warning";
    }
  }

  @override
  Widget build(BuildContext context) {
    // var responded;
    // var alertStatus;
    // void toggleAlert (responded) {}

    // if (responded == 0) {
    //   alertStatus = sendAlert();
    // } else {
    //   alertStatus = alertSent(response: responded);
    // }

    return ChangeNotifierProvider(
      create: (_) => MyState(),
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
                        padding: EdgeInsets.fromLTRB(0, 40, 0, 30),
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
                                      Icons.crisis_alert_sharp,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  Text(
                                    "Out of Safe Zone",
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
                                  const Text(
                                      "Known to travel out of safe zone. Likes to hang out at Bishan Park.",
                                      style: TextStyle(
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
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              height: 200,
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
                                    Spacer(),
                                    Icon(Icons.edit)
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
        floatingActionButton: Container(
            height: 80,
            width: 80,
            child: FittedBox(
              child: FloatingActionButton(
                //Floating action button on Scaffold
                onPressed: () {
                  //code to execute on bxutton press
                },
                child: Icon(Icons.add),
                backgroundColor:
                    Theme.of(context).colorScheme.primary, //icon inside button
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          //bottom navigation bar on scaffold
          height: 80,
          color: Theme.of(context).colorScheme.tertiary,
          shape: CircularNotchedRectangle(), //shape of notch
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
      print("updated child");
      print(myState._alert_sent);
      return myState._alert_sent
          ? Column(
              children: [
                //button
                Container(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        //send alert
                        myState.respondButton(model);
                        print("revert to no response");
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 50),
                          backgroundColor: Colors.grey),
                      child: const Text(
                        'Alert Sent',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                //text below button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Text(
                    '1 Volunteer(s) Responded',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
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
                          flex: 6, // 60%
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 20, 0, 20),
                                  child: Wrap(children: const [
                                    Text(
                                      "Sarah",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Color(0xFF263238),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ])),
                              // const Padding(
                              //   padding: EdgeInsets.fromLTRB(20, 5, 0, 20),
                              //   child: Text("250m away",
                              //       style: TextStyle(fontSize: 12.0)),
                              // ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4, // 40%
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                            child: ElevatedButton(
                              onPressed: () {
                                //do nothing
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(100, 45),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary),
                              child: Text(
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
            )
          : Column(
              children: [
                //button
                Container(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        //send alert
                        myState.respondButton(model);
                        print("responded");
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 50),
                          backgroundColor: Color(0xFFF8E3E4)),
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
