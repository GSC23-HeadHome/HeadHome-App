import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/caregiverdata.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/soslogdata.dart';
import 'package:headhome/api/models/volunteerdata.dart';
import 'package:headhome/constants.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ---------- CARERECEIVER METHODS ----------
  static Future<http.Response> createCarereceiver(
      String id, String name, String address, String contactNum) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}');

    Map data = {
      'CrId': id,
      'Name': name,
      'Address': address,
      'ContactNum': contactNum,
      'CareGiver': [],
    };

    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  static Future<CarereceiverModel?> getCarereceiver(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id');
      var response = await http.get(url);
      print(response.body);
      if (response.statusCode == 200) {
        CarereceiverModel model = carereceiverFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  static Future<http.Response> updateCarereceiver(String id, String name,
      String address, String contactNum, String cgId, String relation) async {
    Uri url =
        Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id');
    print(url);
    Map data = {
      'Name': name,
      'Address': address,
      'ContactNum': contactNum,
      'CareGiver': [
        {'id': cgId, 'relationship': relation}
      ],
    };

    var body = json.encode(data);

    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  static Future<http.Response> updateCarereceiverLoc(
      String id, Position pos, String status) async {
    int datetime =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    String travelLogId = id + datetime.toString();
    Uri url = Uri.parse(
        '${ApiConstants.baseUrl}/${ApiConstants.travellog}/$travelLogId');
    debugPrint(pos.latitude.toString());
    debugPrint(pos.longitude.toString());
    Map data = {
      "CrId": id,
      "Datetime": datetime,
      "CurrentLocation": {"Lat": pos.latitude, "Lng": pos.longitude},
      "Status": status
    };

    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  static Future<http.Response> requestHelp(
      String id, Position startPos, String endLat, String endLng) async {
    int datetime =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    Uri url = Uri.parse(
        '${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id/help');

    Map data = {
      "CrId": id,
      "Body": "Outside of safezone for too long / Routing service triggered",
      "Start": '${startPos.latitude},${startPos.longitude}',
      "End": '$endLat,$endLng',
      "Datetime": datetime,
    };

    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  static Future<http.Response> routingHelp(
      Position startPos, String endLat, String endLng) async {
    Uri url =
        Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/route');
    Map data = {
      "Start": '${startPos.latitude},${startPos.longitude}',
      "End": '$endLat,$endLng',
    };

    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  // ------- END OF CARERECEIVER METHODS -------

  // ------------ CAREGIVER METHODS ------------
  static Future<http.Response> createCaregiver(
      String id, String name, String address, String contactNum) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.caregiver}');

    Map data = {
      'CgId': id,
      'Name': name,
      'Address': address,
      'ContactNum': contactNum,
      'CareReceiver': [],
    };

    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    return response;
  }

  static Future<CaregiverModel?> getCaregiver(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.caregiver}/$id');
      print(url);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        CaregiverModel model = caregiverFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  static Future<Cgcontactnum?> getCgContact(String cgId, crId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://HeadHome.chayhuixiang.repl.co/carereceiver/contactcg'));
    print("$cgId $crId");
    request.body = json.encode({"CrId": crId, "CgId": cgId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      Cgcontactnum model = cgcontactnumFromJson(res);
      return model;
    } else {
      print(response.reasonPhrase);
      return null;
    }
  }

  static Future<UpdateCgResponse> updateCg(String contact, String cgId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('PUT',
        Uri.parse('https://HeadHome.chayhuixiang.repl.co/caregiver/${cgId}'));
    request.body = json.encode({"ContactNum": contact});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      UpdateCgResponse model = updateCgResponseFromJson(res);
      return model;
    } else {
      throw Exception('Failed to update CG: ${response.reasonPhrase}');
    }
  }

  static Future<SosMessage> sendSOS(String crId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://HeadHome.chayhuixiang.repl.co/sos'));
    request.body = json.encode({
      "CrId": crId,
      "Datetime": 1677280000,
      "StartLocation": {"Lat": 1.34176, "Lng": 103.846836},
      "Status": "home",
      "Volunteer": ""
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 202) {
      var res = await response.stream.bytesToString();
      SosMessage model = sosMessageFromJson(res);
      print("alert sent");
      return model;
    } else {
      throw Exception('Failed to send SOS: ${response.reasonPhrase}');
    }
  }

  static Future<AddPatientMessage> addPatient(
      String cgId, String crId, String relationship) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'PUT',
        Uri.parse(
            'https://HeadHome.chayhuixiang.repl.co/caregiver/${cgId}/newcr'));
    request.body = json.encode({"Id": crId, "Relationship": relationship});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 202) {
      var res = await response.stream.bytesToString();
      AddPatientMessage model = addPatientMessageFromJson(res);
      print("alert sent");
      return model;
    } else {
      throw Exception('Failed to add patient: ${response.reasonPhrase}');
    }
  }

  // -------- END OF CAREGIVER METHODS ---------

  // ------------ VOLUNTEER METHODS ------------
  static Future<http.Response> createVolunteer(
      String id, String name, String contactNum) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.volunteers}');

    int certificationStart = 1609459200 + Random().nextInt(5097600);
    int certificationEnd = 1672531200 + Random().nextInt(5097600);

    Map data = {
      'VId': id,
      'Name': name,
      'ContactNum': contactNum,
      'CertificationStart': certificationStart,
      'CertificationEnd': certificationEnd,
      'ProfilePic': "",
    };

    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    return response;
  }

  static Future<VolunteerModel?> getVolunteer(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.volunteers}/$id');
      print(url);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        VolunteerModel model = volunteerFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  static Future<UpdateVolResponse> updateVolunteer(
      String contact, String vId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('PUT',
        Uri.parse('https://HeadHome.chayhuixiang.repl.co/volunteers/${vId}'));
    request.body = json.encode({"ContactNum": contact});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      UpdateVolResponse model = updateVolResponseFromJson(res);
      return model;
    } else {
      throw Exception(
          'Failed to update volunteer info: ${response.reasonPhrase}');
    }
  }

  // -------- END OF VOLUNTEER METHODS ---------

  // ------------- SOS LOG METHODS -------------

  static Future<AcceptSOSResponse?> acceptSOS(
      String sosId, String authID, String vId) async {
    var headers = {'Content-Type': 'application/json'};
    String url = '${ApiConstants.baseUrl}/${ApiConstants.sos}/accept';
    log(url);
    var request = http.Request('PUT', Uri.parse(url));
    request.body = json.encode({"SOSId": sosId, "AuthID": authID, "VId": vId});
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        AcceptSOSResponse model = acceptSOSFromJson(res);
        return model;
      } else {
        throw Exception('Failed to accept SOS: ${response.reasonPhrase}');
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // --------- END OF SOS LOG METHODS ----------
}
