import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/soslogdata.dart';
import 'package:headhome/api/models/volunteerdata.dart';

class PatientPage extends StatefulWidget {
  const PatientPage(
      {super.key,
      required this.carereceiverModel,
      required this.imageUrl,
      required this.sosLogModel,
      required this.volunteerModel});
  final CarereceiverModel carereceiverModel;
  final String imageUrl;
  final Map<String, dynamic> sosLogModel;
  final VolunteerModel volunteerModel;

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  String _priContactNo = "-";

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

  @override
  void initState() {
    super.initState();
    fetchCgNumber();
  }

  @override
  Widget build(BuildContext context) {
    bool authenticated = false;

    void updateAuthenticated(bool newAuthenticated) {
      setState(() {
        authenticated = newAuthenticated;
      });
    }

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
                  scrollDirection:
                      Axis.vertical, // set the direction of scrolling
                  children: <Widget>[
                    // list of widgets that you want to scroll through
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                      child: Column(
                        children: [
                          Text("Amy Zhang",
                              style: Theme.of(context).textTheme.displayMedium),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(widget.imageUrl),
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
                                color: Theme.of(context).colorScheme.error),
                          )
                        ],
                      ),
                    ),
                    authenticated
                        ? findPatient(
                            priContactNo: _priContactNo,
                            sosLogModel: widget.sosLogModel,
                            volunteerModel: widget.volunteerModel,
                            updateAuthenticated: updateAuthenticated)
                        : findHome(
                            priContactNo: _priContactNo,
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
              onPressed: () async {
                //code to execute on bxutton press
                await FlutterPhoneDirectCaller.callNumber(
                    widget.carereceiverModel.contactNum.replaceAll(' ', ''));
              },
              child: Icon(Icons.call),
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
    );
  }
}

class findPatient extends StatefulWidget {
  findPatient({
    super.key,
    required this.priContactNo,
    required this.sosLogModel,
    required this.volunteerModel,
    required this.updateAuthenticated,
  });
  final String priContactNo;
  final Map<String, dynamic> sosLogModel;
  final VolunteerModel volunteerModel;
  final void Function(bool) updateAuthenticated;

  @override
  State<findPatient> createState() => _findPatientState();
}

class _findPatientState extends State<findPatient> {
  final authIdController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    authIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(
                children: [
                  Text("Enter Patient's Authentication ID",
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Container(
              child: TextField(
                controller: authIdController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.send_outlined,
                    ),
                    onPressed: () async {
                      AcceptSOSResponse? response = await ApiService.acceptSOS(
                          widget.sosLogModel["sos_id"],
                          authIdController.text,
                          widget.volunteerModel.vId);
                      debugPrint("$response");
                      if (response != null) {
                        widget.updateAuthenticated(true);
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        width: 1, color: Colors.grey), //<-- SEE HERE
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            )
          ]),
        ),
        //google map widget
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(
                children: [
                  Text("Caregiver Information",
                      style: Theme.of(context).textTheme.titleSmall),
                  Spacer(),
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
                              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                              child: Wrap(children: const [
                                Text(
                                  "Sarah",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF263238),
                                      fontWeight: FontWeight.w600),
                                ),
                              ])),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                            child: Text(widget.priContactNo,
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
          ]),
        ),
      ],
    );
  }
}

class findHome extends StatelessWidget {
  const findHome({super.key, required this.priContactNo});
  final String priContactNo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //google map widget
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text("Home Location",
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(
                children: [
                  Text("Caregiver Information",
                      style: Theme.of(context).textTheme.titleSmall),
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
                              padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                              child: Wrap(children: const [
                                Text(
                                  "Sarah",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF263238),
                                      fontWeight: FontWeight.w600),
                                ),
                              ])),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                            child: Text(priContactNo,
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
                            //send alert
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
          ]),
        ),
      ],
    );
  }
}
