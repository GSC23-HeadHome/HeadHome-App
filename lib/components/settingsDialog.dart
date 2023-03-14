import 'dart:math';

import 'package:flutter/material.dart';

class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({Key? key}) : super(key: key);

  @override
  __SettingsOverlayState createState() => __SettingsOverlayState();
}

class __SettingsOverlayState extends State<SettingsOverlay> {
  OverlayEntry? overlayEntry;
  bool notifications = true;
  bool show = false;
  void _showOverlay(BuildContext context) async {
    setState(() {
      show = !show;
    });

    OverlayState? overlayState = Overlay.of(context);

    if (show) {
      overlayEntry = OverlayEntry(builder: (context) {
        return Dialog(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.height * 0.02,
                  MediaQuery.of(context).size.height * 0.02,
                  MediaQuery.of(context).size.height * 0.02,
                  MediaQuery.of(context).size.height * 0.45),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6, // 60%
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                              padding: EdgeInsets.fromLTRB(20, 20, 0, 5),
                              child: Text(
                                "Notifications",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Color(0xFF263238),
                                    fontWeight: FontWeight.w500),
                              )),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 0, 10),
                              child: Wrap(children: const [
                                Text(
                                  "Alerts when patient is out of safe zone",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF263238),
                                      fontWeight: FontWeight.w400),
                                ),
                              ])),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Switch(
                        // thumb color (round icon)
                        activeColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        inactiveThumbColor: Colors.blueGrey.shade600,
                        inactiveTrackColor: Colors.grey.shade400,
                        splashRadius: 50.0,
                        // boolean variable value
                        value: notifications,
                        // changes the state of the switch
                        onChanged: (value) =>
                            setState(() => notifications = !notifications),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      });
      overlayState.insert(overlayEntry!);
    } else {
      overlayEntry!.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {
        _showOverlay(context);
      },
    );
  }
}
