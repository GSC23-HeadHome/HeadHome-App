import 'package:flutter/material.dart';
import 'package:headhome/api/models/volunteerdata.dart';
import '../main.dart' show MyApp;
import './volunteerPatient.dart' show PatientPage;

class Volunteer extends StatelessWidget {
  const Volunteer({super.key, this.volunteerModel});
  final VolunteerModel? volunteerModel;

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                child: Column(
                  children: [
                    const Text("Welcome back,",
                        style: TextStyle(
                            fontSize: 18.0, color: Color(0xFF263238))),
                    Text("Sarah",
                        style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
              //google map widget
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  height: 200,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Text("Patients Near You",
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    const Text(
                      "Help locate these patients and bring them home to their worried caregivers.",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF263238),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              //patients near you
              Expanded(
                child: Scrollbar(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ListView(
                      scrollDirection:
                          Axis.vertical, // set the direction of scrolling
                      children: <Widget>[
                        // list of widgets that you want to scroll through
                        PatientDetails(
                            name: "Sarah",
                            distance: "250m away",
                            imageurl: "https://picsum.photos/id/237/200/300"),
                        PatientDetails(
                            name: "Amy",
                            distance: "250m away",
                            imageurl: "https://picsum.photos/id/237/200/300"),
                        PatientDetails(
                            name: "Bryan",
                            distance: "250m away",
                            imageurl: "https://picsum.photos/id/237/200/300")
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        height: 80,
        color: Theme.of(context).colorScheme.tertiary,
        shape: CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            //children inside bottom appbar
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 5, // 50%
                child: IconButton(
                  icon: Icon(
                    Icons.person_2_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ),
              Expanded(
                flex: 5, // 50%
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientDetails extends StatelessWidget {
  final String name;
  final String distance;
  final String imageurl;

  const PatientDetails(
      {super.key,
      required this.name,
      required this.distance,
      required this.imageurl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8E3E4),
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
                  flex: 2, // 60%
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(imageurl),
                    ),
                  )),
              Expanded(
                flex: 4, // 60%
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                        child: Wrap(children: [
                          Text(
                            name,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFF263238),
                                fontWeight: FontWeight.w600),
                          ),
                        ])),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                      child: Text(distance, style: TextStyle(fontSize: 12.0)),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PatientPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 45),
                        backgroundColor: Theme.of(context).colorScheme.error),
                    child: Text(
                      'Locate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
