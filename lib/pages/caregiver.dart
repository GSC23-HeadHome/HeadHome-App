import 'package:flutter/material.dart';
import 'package:headhome/api/models/caregiverdata.dart';
import '../main.dart' show MyApp;
import './caregiverPatient.dart' show PatientDetails;
import '../components/profileDialog.dart' show ProfileOverlay;
import '../components/settingsDialog.dart' show SettingsOverlay;
import '../components/addPatient.dart' show AddPatientOverlay;

import 'package:headhome/api/api_services.dart';

import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/carereceiverdata.dart';

class Caregiver extends StatefulWidget {
  const Caregiver({super.key, this.caregiverModel});
  final CaregiverModel? caregiverModel;

  @override
  State<Caregiver> createState() => _CaregiverState();
}

class _CaregiverState extends State<Caregiver> {
  late CaregiverModel? _CaregiverModel = {} as CaregiverModel?;
  late CarereceiverModel? _CarereceiverModel = {} as CarereceiverModel?;
  // late Cgcontactnum? _cgcontactnumModel = {} as Cgcontactnum?;
  //caregiver details
  late String CgId = widget.caregiverModel?.cgId ?? "cg0002";

  late String nameValue = widget.caregiverModel?.name ?? "John";

  late String contactNum = widget.caregiverModel?.contactNum ?? "69823042";

  late String password = "69823042";

  late List<CareReceiver> careReceivers = [];
  late List<CarereceiverModel?> careReceiverDetails = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    print("getdata function");
    // if (widget.caregiverModel != null) {
    //   print("caregiverModel not null");
    //   _getCaregiverInfo(widget.caregiverModel!.cgId);
    // }
    _getCaregiverInfo(CgId);
  }

  void _getCaregiverInfo(cgId) async {
    _CaregiverModel = await ApiService.getCaregiver(cgId);
    setState(() {
      nameValue = _CaregiverModel!.name;
      contactNum = _CaregiverModel!.contactNum;
      careReceivers = _CaregiverModel!.careReceiver;
    });
    //get all careReceivers
    for (var i = 0; i < careReceivers.length; i++) {
      // TO DO
      _CarereceiverModel =
          await ApiService.getCarereceiver(careReceivers[i].id);
      setState(() {
        careReceiverDetails.add(_CarereceiverModel);
      });
      // add to careReceiverDetails
    }
  }
  

  Future<String> _updateCgInfo(
      String _cgid, String _name, String _contact, String _password) async {
    //set states of parent widget
    setState(() {
      nameValue = _name;
      contactNum = _contact;
      password = _password;
    });

    //send put request to update caregiver num
    var response = await ApiService.updateCg(contactNum, _cgid);
    print(response.message);
    return response.message;
    //get all careReceiver
  }

    Future<String> _addNewPatient(String cgId, String crId, String relationship) async {

     var response = await ApiService.addPatient(cgId, crId, relationship);
    print(response.message);
    return response.message;
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
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
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Container(
                      width: 350,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // mainAxisSize: MainAxisSize.values,
                        children: [
                          Container(),
                          Container(
                            child: Text("Select Patient",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center),
                          ),
                          Container(
                            child: Icon(Icons.edit),
                          )
                        ],
                      ),
                    )),
                SizedBox(
                  height: 480,
                  child: ListView.builder(
                      itemCount: careReceiverDetails.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Card(
                          elevation: 0,
                          color: Colors.transparent,
                          surfaceTintColor: Colors.white,
                          child: CaregiverPatients(
                              model: careReceiverDetails[i]!,
                              name: careReceiverDetails[i]!.name,
                              note:
                                  "Known to leave safe zone. Hangs out in ang mo kio park",
                              status: "danger",
                              //change imageurl to careReceiverDetails[i]!.profilePic
                              imageurl: "https://picsum.photos/id/237/200/300"),
                        );
                      }),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
          height: 80,
          width: 80,
          child: FittedBox(
            child: AddPatientOverlay(addNewPatient: _addNewPatient,)),
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        height: 80,
        color: Theme.of(context).colorScheme.tertiary,
        shape: CircularNotchedRectangle(), //shape of notch
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
                  id: CgId,
                )),
            Expanded(
              flex: 5, // 50%
              child: SettingsOverlay(),
            ),
          ],
        ),
      ),
    );
  }
}

class CaregiverPatients extends StatelessWidget {
  const CaregiverPatients(
      {super.key,
      required this.name,
      required this.note,
      required this.status,
      required this.imageurl,
      required this.model});

  final String name;
  final String note;
  final String status;
  final String imageurl;
  final CarereceiverModel model;

  @override
  Widget build(BuildContext context) {
    var statusText = "invalid status";
    var containerColour = Colors.white;
    var statusTextColour = Color(0xFF263238);

    if (status == "danger") {
      statusText = "Out of Safe Zone";
      containerColour = Color(0xFFF8E3E4);
      statusTextColour = Theme.of(context).colorScheme.error;
    } else if (status == "safe") {
      statusText = "Within Safe Zone";
      containerColour = Colors.white;
      statusTextColour = Theme.of(context).colorScheme.primary;
    } else if (status == "home") {
      statusText = "At Home";
      containerColour = Colors.white;
      statusTextColour = Theme.of(context).colorScheme.secondary;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: GestureDetector(
          onTap: () {
            print("clicked");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientDetails(
                        CarereceiverModel: model,
                      )),
            );
          },
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: containerColour,
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
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 5),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xFF263238),
                                fontWeight: FontWeight.w500),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 0, 10),
                          child: Wrap(children: [
                            Text(
                              note,
                              style: TextStyle(
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
                    backgroundImage: NetworkImage(imageurl),
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
