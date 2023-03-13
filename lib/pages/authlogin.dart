import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  String dropdownValue = "Caregiver";
  String emailValue = "";
  String passwordValue = "";
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
        value: "Caregiver",
        child: Text("Caregiver"),
      ),
      const DropdownMenuItem(
        value: "Patient",
        child: Text("Patient"),
      ),
      const DropdownMenuItem(
        value: "Volunteer",
        child: Text("Volunteer"),
      ),
    ];
    return menuItems;
  }

  void loginAccount() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailValue, password: passwordValue);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40.0,
                left: 50.0,
                right: 50.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Text(
                    "HeadHome",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 50.0,
                      bottom: 30.0,
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'I am a',
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      child: ButtonTheme(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        child: DropdownButton<String>(
                          hint: const Text("I am a"),
                          isExpanded: true,
                          value: dropdownValue,
                          elevation: 16,
                          underline: DropdownButtonHideUnderline(
                            child: Container(),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: <String>['Caregiver', 'Patient', 'Volunteer']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: 'Enter Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        emailValue = newValue!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: 'Enter Password',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    obscureText: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        passwordValue = newValue!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50), //////// HERE
                    ),
                    onPressed: () {
                      loginAccount();
                      // Navigator.pop(context);
                    },
                    child: const Text("Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
