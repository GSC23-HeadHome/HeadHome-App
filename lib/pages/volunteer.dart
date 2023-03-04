import 'package:flutter/material.dart';

class Volunteer extends StatelessWidget {
  const Volunteer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(children: [
            const Text("volunteer home page"),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ]),
        ),
      ),
    );
  }
}
