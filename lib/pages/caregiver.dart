import 'package:flutter/material.dart';
import '../main.dart' show MyApp;

class Caregiver extends StatelessWidget {
  const Caregiver({super.key});

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
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
              child: Column(
                children: [
                  const Text("Welcome back,",
                      style:
                          TextStyle(fontSize: 18.0, color: Color(0xFF263238))),
                  Text("John",
                      style: Theme.of(context).textTheme.displayMedium),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Select Patient",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.edit),
                    )
                  ],
                ),
                // Expanded(child: SizedBox(width: 200,
                const Column(
                  children: [
                    CaregiverPatients(
                        name: "Amy Zhang",
                        note:"Known to leave safe zone. Hangs out in ang mo kio park",
                        status: "danger",
                        imageurl: "https://picsum.photos/id/237/200/300"),
                    CaregiverPatients(
                        name: "David Teo",
                        note: "testtest",
                        status: "safe",
                        imageurl: "https://picsum.photos/id/237/200/300"),
                    CaregiverPatients(
                        name: "Mary Ang",
                        note: "testtest",
                        status: "home",
                        imageurl: "https://picsum.photos/id/237/200/300")
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CaregiverPatients extends StatelessWidget {
  const CaregiverPatients(
      {Key? key,
      required this.name,
      required this.note,
      required this.status,
      required this.imageurl});

  final String name;
  final String note;
  final String status;
  final String imageurl;

  @override
  Widget build(BuildContext context) {
    var statusText = "invalid status";
    var containerColour = Colors.white;
    var statusTextColour = Color(0xFF263238);

    if (status == "danger") {
      statusText = "Out of Safe Zone";
      containerColour = Color(0xFFF8E3E4);
      statusTextColour =  Theme.of(context).colorScheme.error;
    } else if (status == "safe") {
      statusText = "Within Safe Zone";
      containerColour = Colors.white;
      statusTextColour =  Theme.of(context).colorScheme.primary;
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
                        child: Text(name,
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
                          child: Wrap(children: [
                            Text(note,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ])),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                        child: Text(statusText,
                            style: TextStyle(fontSize: 12.0, color: statusTextColour)),
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
