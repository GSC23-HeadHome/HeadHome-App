// To parse this JSON data, do
//
//     final acceptSOSResponse = acceptSOSFromJson(jsonString);

import 'dart:convert';

AcceptSOSResponse acceptSOSFromJson(String str) =>
    AcceptSOSResponse.fromJson(json.decode(str));

String acceptSOSToJson(AcceptSOSResponse data) => json.encode(data.toJson());

class AcceptSOSResponse {
  AcceptSOSResponse({
    required this.message,
  });

  Message message;

  factory AcceptSOSResponse.fromJson(Map<String, dynamic> json) =>
      AcceptSOSResponse(
        message: Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
      };
}

class Message {
  Message({
    required this.address,
    required this.cgContactNum,
    required this.cgName,
    required this.contactNum,
    required this.crId,
    required this.name,
    required this.routeGeom,
  });

  String address;
  String cgContactNum;
  String cgName;
  String contactNum;
  String crId;
  String name;
  String routeGeom;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        address: json["Address"],
        cgContactNum: json["CgContactNum"],
        cgName: json["CgName"],
        contactNum: json["ContactNum"],
        crId: json["CrId"],
        name: json["Name"],
        routeGeom: json["RouteGeom"],
      );

  Map<String, dynamic> toJson() => {
        "Address": address,
        "CgContactNum": cgContactNum,
        "CgName": cgName,
        "ContactNum": contactNum,
        "CrId": crId,
        "Name": name,
        "RouteGeom": routeGeom,
      };
}

SosLogModel sosLogModelFromJson(String str) =>
    SosLogModel.fromJson(json.decode(str));

String sosLogModelToJson(SosLogModel data) => json.encode(data.toJson());

class SosLogModel {
  SosLogModel({
    required this.crId,
    required this.datetime,
    required this.sosId,
    required this.startLocation,
    required this.status,
    required this.vId,
    required this.volunteer,
    required this.volunteerContactNum,
  });

  String crId;
  int datetime;
  String sosId;
  StartLocation startLocation;
  String status;
  String vId;
  String volunteer;
  String volunteerContactNum;

  factory SosLogModel.fromJson(Map<String, dynamic> json) => SosLogModel(
        crId: json["CrId"],
        datetime: json["Datetime"],
        sosId: json["SOSId"],
        startLocation: StartLocation.fromJson(json["StartLocation"]),
        status: json["Status"],
        vId: json["VId"],
        volunteer: json["Volunteer"],
        volunteerContactNum: json["VolunteerContactNum"],
      );

  Map<String, dynamic> toJson() => {
        "CrId": crId,
        "Datetime": datetime,
        "SOSId": sosId,
        "StartLocation": startLocation.toJson(),
        "Status": status,
        "VId": vId,
        "Volunteer": volunteer,
        "VolunteerContactNum": volunteerContactNum,
      };
}

class StartLocation {
  StartLocation({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory StartLocation.fromJson(Map<String, dynamic> json) => StartLocation(
        lat: json["Lat"]?.toDouble(),
        lng: json["Lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Lat": lat,
        "Lng": lng,
      };
}
