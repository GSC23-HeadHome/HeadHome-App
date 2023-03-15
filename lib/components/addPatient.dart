import 'package:flutter/material.dart';

class AddPatientOverlay extends StatefulWidget {
  const AddPatientOverlay({Key? key, required this.addNewPatient})
      : super(key: key);

  final Function(String, String, String) addNewPatient;

  @override
  __AddPatientOverlayState createState() => __AddPatientOverlayState();
}

class __AddPatientOverlayState extends State<AddPatientOverlay> {
  void showAddPatient() {
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
                "Add Patient",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            content: SizedBox(
              height: 315,
              width: 550,
              child: ListView(
                  scrollDirection:
                      Axis.vertical, // set the direction of scrolling
                  children: <Widget>[
                    // list of widgets that you want to scroll through
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                      child: Column(
                        children: [
                          Text("AuthId of patient can be found on patient's account.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'AuthId',
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                hintText: "e.g. amyzhang001",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              onChanged: (String? newValue) {
                                // setState(() {
                                //   localName = newValue!;
                                // });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Relationship',
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                hintText: "e.g. Father",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              onChanged: (String? newValue) {
                                // setState(() {
                                //   localNum = newValue!;
                                // });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 1, // the thickness
                                            color: Colors
                                                .grey // the color of the border
                                            ),
                                        minimumSize: const Size(120, 50),
                                        backgroundColor: (Colors.white)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      //addNewPatient(authid, relationship) 
                                    },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(120, 50),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ]),
                          ),
                          // updateAttempt
                          //     ? (updateSuccess
                          //         ? Text("Update Successful", style: TextStyle(color: Colors.black),)
                          //         : Text("Update Failed. Try Again", style: TextStyle(color: Colors.black)))
                          //     : Text("Update test", style: TextStyle(color: Colors.black),),
                          // Text(
                          //   updateAttempt
                          //       ? (updateSuccess
                          //           ? "Update Successful"
                          //           : "Update Failed. Try again.")
                          //       : "Did not submit",
                          //   style: TextStyle(
                          //       color:
                          //           updateSuccess ? Colors.green : Colors.red),
                          // ),
                        ],
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      //Floating action button on Scaffold
      onPressed: () {
        //code to execute on bxutton press
        showAddPatient();
      },
      child: Icon(Icons.add),
      backgroundColor:
          Theme.of(context).colorScheme.primary, //icon inside button
    );
  }
}
