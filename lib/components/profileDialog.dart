import 'package:flutter/material.dart';

class ProfileOverlay extends StatefulWidget {
  const ProfileOverlay({Key? key}) : super(key: key);

  @override
  __ProfileOverlayState createState() => __ProfileOverlayState();
}

class __ProfileOverlayState extends State<ProfileOverlay> {
  OverlayEntry? overlayEntry;
  bool show = false;
  void _showOverlay(BuildContext context) async {
    setState(() {
      show = !show;
    });

    OverlayState? overlayState = Overlay.of(context);

    if (show) {
      overlayEntry = OverlayEntry(builder: (context) {
        return Dialog(
          child: Positioned(
            left: MediaQuery.of(context).size.width * 0.1,
            top: MediaQuery.of(context).size.height * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  color: Colors.white,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Scrollbar(
                          child: ListView(
                              scrollDirection: Axis
                                  .vertical, // set the direction of scrolling
                              children: <Widget>[
                                // list of widgets that you want to scroll through
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Column(
                                    children: [
                                      Text("Edit Profile",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 20, 0, 5),
                                        child: Text("Amy Zhang",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium),
                                      ),
                                      Text("Caregiver",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 20, 5, 10),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Name',
                                            labelStyle: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    15, 20, 15, 20),
                                            hintText: 'John Chan',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                          ),
                                          onChanged: (String? newValue) {
                                            // setState(() {
                                            //   distanceValue = newValue!;
                                            // });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 5, 10),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Phone Number',
                                            labelStyle: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    15, 20, 15, 20),
                                            hintText: '69823042',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                          ),
                                          onChanged: (String? newValue) {
                                            // setState(() {
                                            //   distanceValue = newValue!;
                                            // });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 5, 10),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    15, 20, 15, 20),
                                            hintText: '******',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                          ),
                                          obscureText: true,
                                          onChanged: (String? newValue) {
                                            // setState(() {
                                            //   distanceValue = newValue!;
                                            // });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 20, 5, 0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    side: const BorderSide(
                                                        width:
                                                            1, // the thickness
                                                        color: Colors
                                                            .black // the color of the border
                                                        ),
                                                    minimumSize:
                                                        const Size(120, 50),
                                                    backgroundColor:
                                                        (Colors.white)),
                                                onPressed: () {
                                                  //close overlay
                                                  setState(() {
                                                    show = !show;
                                                  });
                                                  overlayEntry!.remove();
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  //send alert
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    minimumSize: Size(120, 50),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary),
                                                child: Text(
                                                  'Save',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )
                                            ]),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        );
      });
      overlayState.insert(overlayEntry!);
    } else {
      overlayEntry!.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialButton(
    //   color: Colors.pink[300],
    //   minWidth: MediaQuery.of(context).size.width * 0.4,
    //   height: MediaQuery.of(context).size.height * 0.06,
    //   child: const Text(
    //     'show Overlay',
    //     style: TextStyle(color: Colors.white, fontSize: 17),
    //   ),
    //   onPressed: () {
    //     _showOverlay(context);
    //   },
    // );
    return IconButton(
      icon: Icon(
        Icons.person_2_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {
        _showOverlay(context);
      },
    );
  }
}
