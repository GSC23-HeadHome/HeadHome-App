// To parse this JSON data, do
//
//     final carereceiver = carereceiverFromJson(jsonString);

import 'dart:convert';

import 'package:headhome/api/api_services.dart';
import 'package:headhome/api/models/soslogdata.dart';
import 'package:headhome/api/models/travellogdata.dart';

CarereceiverModel carereceiverFromJson(String str) =>
    CarereceiverModel.fromJson(json.decode(str));

String carereceiverToJson(CarereceiverModel data) => json.encode(data.toJson());

class CarereceiverModel {
  CarereceiverModel({
    required this.crId,
    required this.name,
    required this.address,
    required this.contactNum,
    required this.safezoneCtr,
    required this.safezoneRadius,
    required this.careGiver,
    required this.profilePic,
    required this.authId,
  });

  String crId;
  String name;
  String address;
  String contactNum;
  SafezoneCtr safezoneCtr;
  int safezoneRadius;
  List<CareGiver> careGiver;
  String profilePic;
  String authId;
  TravelLogModel? travellog;
  SosLogModel? soslog;

  factory CarereceiverModel.fromJson(Map<String, dynamic> json) =>
      CarereceiverModel(
        crId: json["CrId"],
        name: json["Name"],
        address: json["Address"],
        contactNum: json["ContactNum"],
        safezoneCtr: SafezoneCtr.fromJson(json["SafezoneCtr"]),
        safezoneRadius: json["SafezoneRadius"],
        careGiver: List<CareGiver>.from(json["CareGiver"] == null
            ? []
            : json["CareGiver"].map((x) => CareGiver.fromJson(x))),
        profilePic: json["ProfilePic"],
        authId: json["AuthID"],
      );

  Map<String, dynamic> toJson() => {
        "CrId": crId,
        "Name": name,
        "Address": address,
        "ContactNum": contactNum,
        "SafezoneCtr": safezoneCtr.toJson(),
        "SafezoneRadius": safezoneRadius,
        "CareGiver": List<dynamic>.from(careGiver.map((x) => x.toJson())),
        "ProfilePic": profilePic,
        "AuthID": authId,
      };

  Future<void> getCRTravelLog() async {
    travellog = await ApiService.getTravelLog(crId);
  }

  Future<void> getCRSOSLog() async {
    soslog = await ApiService.getSOSLog(crId);
  }
}

class CareGiver {
  CareGiver({
    required this.id,
    required this.relationship,
  });

  String id;
  String relationship;

  factory CareGiver.fromJson(Map<String, dynamic> json) => CareGiver(
        id: json["Id"],
        relationship: json["Relationship"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Relationship": relationship,
      };
}

class SafezoneCtr {
  SafezoneCtr({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory SafezoneCtr.fromJson(Map<String, dynamic> json) => SafezoneCtr(
        lat: json["Lat"],
        lng: json["Lng"],
      );

  Map<String, dynamic> toJson() => {
        "Lat": lat,
        "Lng": lng,
      };
}
