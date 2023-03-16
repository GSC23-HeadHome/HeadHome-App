// To parse this JSON data, do
//
//     final CaregiverModel = caregiverFromJson(jsonString);

import 'dart:convert';

CaregiverModel caregiverFromJson(String str) =>
    CaregiverModel.fromJson(json.decode(str));

String caregiverToJson(CaregiverModel data) => json.encode(data.toJson());

class CaregiverModel {
  CaregiverModel({
    required this.cgId,
    required this.name,
    required this.address,
    required this.contactNum,
    required this.careReceiver,
    required this.profilePic,
  });

  String cgId;
  String name;
  String address;
  String contactNum;
  List<CareReceiver> careReceiver;
  String profilePic;

  factory CaregiverModel.fromJson(Map<String, dynamic> json) => CaregiverModel(
        cgId: json["CgId"],
        name: json["Name"],
        address: json["Address"],
        contactNum: json["ContactNum"],
        careReceiver: List<CareReceiver>.from(json["CareReceiver"] == null
            ? []
            : json["CareReceiver"].map((x) => CareReceiver.fromJson(x))),
        profilePic: json["ProfilePic"],
      );

  Map<String, dynamic> toJson() => {
        "CgId": cgId,
        "Name": name,
        "Address": address,
        "ContactNum": contactNum,
        "CareReceiver": List<dynamic>.from(careReceiver.map((x) => x.toJson())),
        "ProfilePic": profilePic,
      };
}

class CareReceiver {
  CareReceiver({
    required this.id,
    required this.relationship,
  });

  String id;
  String relationship;

  factory CareReceiver.fromJson(Map<String, dynamic> json) => CareReceiver(
        id: json["Id"],
        relationship: json["Relationship"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Relationship": relationship,
      };
}
