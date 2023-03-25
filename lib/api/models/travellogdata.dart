// To parse this JSON data, do
//
//     final travelLogModel = travelLogModelFromJson(jsonString);

import 'dart:convert';

TravelLogModel travelLogModelFromJson(String str) =>
    TravelLogModel.fromJson(json.decode(str));

String travelLogModelToJson(TravelLogModel data) => json.encode(data.toJson());

class TravelLogModel {
  TravelLogModel({
    required this.crId,
    required this.datetime,
    required this.travelLogId,
    required this.currentLocation,
    required this.status,
  });

  String crId;
  int datetime;
  String travelLogId;
  CurrentLocation currentLocation;
  String status;

  factory TravelLogModel.fromJson(Map<String, dynamic> json) => TravelLogModel(
        crId: json["CrId"],
        datetime: json["Datetime"],
        travelLogId: json["TravelLogId"],
        currentLocation: CurrentLocation.fromJson(json["CurrentLocation"]),
        status: json["Status"],
      );

  Map<String, dynamic> toJson() => {
        "CrId": crId,
        "Datetime": datetime,
        "TravelLogId": travelLogId,
        "CurrentLocation": currentLocation.toJson(),
        "Status": status,
      };
}

class CurrentLocation {
  CurrentLocation({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      CurrentLocation(
        lat: json["Lat"]?.toDouble(),
        lng: json["Lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Lat": lat,
        "Lng": lng,
      };
}
