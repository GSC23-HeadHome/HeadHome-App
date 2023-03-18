import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:headhome/api/api_services.dart';

class AuthRegister extends StatefulWidget {
  const AuthRegister({super.key});

  @override
  State<AuthRegister> createState() => _AuthRegisterState();
}

class _AuthRegisterState extends State<AuthRegister> {
  String dropdownValue = "Caregiver";
  String nameValue = "";
  String emailValue = "";
  String passwordValue = "";
  String confirmValue = "";
  String mobileValue = "";

  void registerAccount() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailValue,
        password: passwordValue,
      );

      if (credential.user == null) {
        throw Exception("User could not be created in Firebase Auth.");
      }

      switch (dropdownValue) {
        case "Caregiver":
          await ApiService.createCaregiver(
            emailValue,
            nameValue,
            "",
            mobileValue,
          );
          break;

        case "Patient":
          await ApiService.createCarereceiver(
            emailValue,
            nameValue,
            "",
            mobileValue,
          );
          debugPrint("Carereceiver Created!");
          break;

        case "Volunteer":
          await ApiService.createVolunteer(
            emailValue,
            nameValue,
            mobileValue,
          );
          debugPrint("Volunteer Created!");
          break;

        default:
          throw Exception("Invalid Dropdown Value");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
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
                      labelText: 'Name',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: 'My name is',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        nameValue = newValue!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
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
                      labelText: 'Mobile Phone',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: const EdgeInsets.all(10),
                      hintText: 'Enter Mobile Number',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (String? newValue) {
                      setState(() {
                        mobileValue = newValue!;
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
                  TextField(
                    decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        contentPadding: const EdgeInsets.all(10),
                        hintText: 'Re-Enter Password',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        errorText: confirmValue == passwordValue
                            ? null
                            : "Passwords are not the same"),
                    obscureText: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        confirmValue = newValue!;
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
                      registerAccount();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Register",
                      // style: Theme.of(context).textTheme.bodySmall,
                    ),
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
