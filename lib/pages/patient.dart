import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:headhome/utils/extensions.dart';

import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/carereceiverdata.dart';

class Patient extends StatefulWidget {
  const Patient({super.key, this.carereceiverModel});
  final CarereceiverModel? carereceiverModel;

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  late CarereceiverModel? _CarereceiverModel = {} as CarereceiverModel?;
  late Cgcontactnum? _cgcontactnumModel = {} as Cgcontactnum?;
  // UI
  bool visible = true;
  bool fade = true;
  // Patient Details
  late String crId = widget.carereceiverModel?.name ?? "Cr0001";
  late String nameValue = widget.carereceiverModel?.name ?? "Amy Zhang";
  late String phoneNumberValue =
      widget.carereceiverModel?.contactNum ?? "69823042";
  late String authenticationID =
      widget.carereceiverModel?.authId ?? "amyzhang001";
  late String passwordValue = "12345678";
  late String priContactUsername = "alice123";
  late String priContactRel = "Eldest Daughter";
  late String priContactNo = "91234567";
  late String homeAddress = widget.carereceiverModel?.address ??
      "Blk 123 Clementi Rd #12-34 S(123456)";

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
                    const CircleAvatar(
                      radius: 100,
                      backgroundImage:
                          NetworkImage("https://picsum.photos/id/237/200/300"),
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
                            nameValue = newValue!;
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
                            phoneNumberValue = newValue!;
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
                          labelText: 'Primary Contact Username',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: priContactUsername,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            priContactUsername = newValue!;
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
                            priContactRel = newValue!;
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
                          labelText: 'Password',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(10),
                          hintText: passwordValue,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        obscureText: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            passwordValue = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
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
    _getData();
  }

  void _getData() async {
    if (widget.carereceiverModel != null &&
        widget.carereceiverModel!.careGiver.length != 0) {
      _getContact(widget.carereceiverModel!.careGiver[0].id);
    }
  }

  void _getContact(cgId) async {
    _cgcontactnumModel = await ApiService.getCgContact(cgId, crId);
    setState(() {
      priContactNo = _cgcontactnumModel!.cgContactNum;
    });
  }

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
                      Text(
                        homeAddress,
                        textScaleFactor: 1.2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade600,
                      spreadRadius: 1,
                      blurRadius: 15,
                      blurStyle: BlurStyle.outer,
                      offset: const Offset(0, 10)),
                ],
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.arrow_upward,
                    size: 100,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 25),
                        children: [
                          TextSpan(
                            text: "Straight ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'for\n'),
                          TextSpan(
                            text: "200m",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 25),
                        children: [
                          TextSpan(
                            text: "     25\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'mins left'),
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
                //code to execute on bxutton press
                print("Called for help");
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
