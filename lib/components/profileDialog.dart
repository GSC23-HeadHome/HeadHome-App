import 'package:flutter/material.dart';

class ProfileOverlay extends StatefulWidget {
  const ProfileOverlay(
      {Key? key,
      required this.name,
      required this.phoneNum,
      required this.password,
      required this.role,
      required this.updateCgInfo})
      : super(key: key);

  final String name;
  final String phoneNum;
  final String password;
  final String role;
  final Function(String, String, String) updateCgInfo;

  @override
  __ProfileOverlayState createState() => __ProfileOverlayState();
}

class __ProfileOverlayState extends State<ProfileOverlay> {
  String localName = '';
  String localNum = '';
  String localPassword = '';
  bool updateSuccess = false;
  bool updateAttempt = false;

  @override
  void initState() {
    super.initState();
    localName = widget.name;
    localNum = widget.phoneNum;
    localPassword = widget.password;
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
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            content: SizedBox(
              height: 450,
              width: 550,
              child: ListView(
                  scrollDirection:
                      Axis.vertical, // set the direction of scrolling
                  children: <Widget>[
                    // list of widgets that you want to scroll through
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                            child: Text(widget.name,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.displayMedium),
                          ),
                          Text("Caregiver",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                hintText: widget.name,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  localName = newValue!;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                hintText: widget.phoneNum,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  localNum = newValue!;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                hintText: "******",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              obscureText: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  localPassword = newValue!;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
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
                                      //send alert
                                      String message =
                                          await widget.updateCgInfo(localName,
                                              localNum, localPassword);

                                      print(message);

                                      setState(() {
                                        updateAttempt = true;
                                      });

                                      print(updateAttempt);

                                      if (message == "successful") {
                                        setState(() {
                                          updateSuccess = true;
                                        });
                                      }
                                      print(updateSuccess);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(120, 50),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: Text(
                                      'Save',
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
                          Builder(
                            builder: (BuildContext context) {
                              return updateAttempt
                                  ? (updateSuccess
                                      ? Text(
                                          "Update Successful",
                                          style: TextStyle(color: Colors.black),
                                        )
                                      : Text(
                                          "Update Failed. Try Again",
                                          style: TextStyle(color: Colors.red),
                                        ))
                                  : Container();
                            },
                          )
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
    return IconButton(
      icon: Icon(
        Icons.person_2_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {
        // _showOverlay(context);
        showEditProfile();
      },
    );
  }
}
