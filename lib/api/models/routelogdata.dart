// To parse this JSON data, do
//
//     final routeLog = routeLogFromJson(jsonString);

import 'dart:convert';

RouteLog routeLogFromJson(String str) => RouteLog.fromJson(json.decode(str));

String routeLogToJson(RouteLog data) => json.encode(data.toJson());

class RouteLog {
  RouteLog({
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.htmlInstructions,
    required this.maneuver,
    required this.polyline,
    required this.travelMode,
  });

  int distance;
  int duration;
  Location startLocation;
  Location endLocation;
  String htmlInstructions;
  String maneuver;
  String polyline;
  String travelMode;

  factory RouteLog.fromJson(Map<String, dynamic> json) => RouteLog(
        distance: json["Distance"],
        duration: json["Duration"],
        startLocation: Location.fromJson(json["StartLocation"]),
        endLocation: Location.fromJson(json["EndLocation"]),
        htmlInstructions: json["HTMLInstructions"],
        maneuver: json["Maneuver"],
        polyline: json["Polyline"],
        travelMode: json["TravelMode"],
      );

  Map<String, dynamic> toJson() => {
        "Distance": distance,
        "Duration": duration,
        "StartLocation": startLocation.toJson(),
        "EndLocation": endLocation.toJson(),
        "HTMLInstructions": htmlInstructions,
        "Maneuver": maneuver,
        "Polyline": polyline,
        "TravelMode": travelMode,
      };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}
