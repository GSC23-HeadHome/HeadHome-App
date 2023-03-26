import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:headhome/api/models/caregiverdata.dart';
import 'package:headhome/pages/authregister.dart';
import 'package:headhome/pages/patient.dart';
import 'package:headhome/pages/caregiver.dart';
import 'package:headhome/pages/volunteer.dart';
import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/volunteerdata.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  String dropdownValue = "Caregiver";
  String emailValue = "";
  String passwordValue = "";

  void loginAccount(BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailValue,
        password: passwordValue,
      );
      if (credential.user != null) {
        switch (dropdownValue) {
          case "Patient":
            CarereceiverModel? carereceiverModel =
                await ApiService.getCarereceiver(emailValue);
            if (carereceiverModel != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext bctx) => Patient(
                    carereceiverModel: carereceiverModel,
                  ),
                ),
              );
              break;
            } else {
              throw Exception("User is not a Carereceiver");
            }

          case "Volunteer":
            VolunteerModel? volunteerModel =
                await ApiService.getVolunteer(emailValue);
            if (volunteerModel != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext bctx) => Volunteer(
                    volunteerModel: volunteerModel,
                  ),
                ),
              );
              break;
            } else {
              throw Exception("User is not a Volunteer");
            }

          case "Caregiver":
            CaregiverModel? caregiverModel =
                await ApiService.getCaregiver(emailValue);
            if (caregiverModel != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext bctx) => Caregiver(
                    caregiverModel: caregiverModel,
                  ),
                ),
              );
              break;
            } else {
              throw Exception("User is not a Caregiver");
            }

          default:
            throw Exception("Invalid Dropdown Value");
        }
      } else {
        throw Exception("User could not be logged in from Firebase Auth.");
      }
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
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
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
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
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
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
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
                        loginAccount(context);
                      },
                      child: const Text("Login"),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext bctx) =>
                                const AuthRegister(),
                          ),
                        );
                      },
                      child: const Text("Register Now"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
