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
