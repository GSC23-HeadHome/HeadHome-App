
import 'package:flutter/material.dart';
import '../main.dart' show MyApp;

class Caregiver extends StatelessWidget {
  const Caregiver({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(
            children: [
          const Text("caregiver home page"),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
            ]
            
          ),
        ),
      ),
    );
  }
}
