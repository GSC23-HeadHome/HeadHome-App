import 'package:flutter/material.dart';

class PatientPage extends StatelessWidget {
  const PatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool reached = false;
    var pageui;

    
    if (reached == false) {
      pageui = findPatient();
    } else {
      pageui = findHome();
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
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          NetworkImage("https://picsum.photos/id/237/200/300"),
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
                    pageui
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

class findPatient extends StatelessWidget {
  const findPatient({super.key});

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
                  Spacer(),
                ],
              ),
            ),
            Container(
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
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
                  borderRadius: BorderRadius.all(Radius.circular(6)),
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
                const Expanded(
                  flex: 6, // 60%
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                          child: Wrap(children: [
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
                        child:
                            Text("91234567", style: TextStyle(fontSize: 12.0)),
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
          ]),
        ),
      ],
    );
  }
}

class findHome extends StatelessWidget {
  const findHome({super.key});

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
                  borderRadius: BorderRadius.all(Radius.circular(6)),
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
                const Expanded(
                  flex: 6, // 60%
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                          child: Wrap(children: [
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
                        child:
                            Text("91234567", style: TextStyle(fontSize: 12.0)),
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
          ]),
        ),
      ],
    );
  }
}
