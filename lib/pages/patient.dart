import 'package:flutter/material.dart';

class Patient extends StatefulWidget {
  const Patient({super.key});

  @override
  State<Patient> createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  bool visible = true;
  bool fade = true;
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
            Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
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
            onPressed: () {},
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
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(
                    "Blk 123 Clementi Rd #12-34 S(123456)",
                    textScaleFactor: 1.2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
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
                  "Eldest Daughter",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.right,
                ),
                Text(
                  "91234567",
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
