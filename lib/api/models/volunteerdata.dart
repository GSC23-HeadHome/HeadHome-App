// To parse this JSON data, do
//
//     final Volunteer = volunteerFromJson(jsonString);

import 'dart:convert';

VolunteerModel volunteerFromJson(String str) =>
    VolunteerModel.fromJson(json.decode(str));

String volunteerToJson(VolunteerModel data) => json.encode(data.toJson());

class VolunteerModel {
  VolunteerModel({
    required this.vId,
    required this.name,
    required this.contactNum,
    required this.certificationStart,
    required this.certificationEnd,
    required this.profilePic,
  });

  String vId;
  String name;
  String contactNum;
  int certificationStart;
  int certificationEnd;
  String profilePic;

  factory VolunteerModel.fromJson(Map<String, dynamic> json) => VolunteerModel(
        vId: json["VId"],
        name: json["Name"],
        contactNum: json["ContactNum"],
        certificationStart: json["CertificationStart"],
        certificationEnd: json["CertificationEnd"],
        profilePic: json["ProfilePic"],
      );

  Map<String, dynamic> toJson() => {
        "VId": vId,
        "Name": name,
        "ContactNum": contactNum,
        "CertificationStart": certificationStart,
        "CertificationEnd": certificationEnd,
        "ProfilePic": profilePic,
      };
}
