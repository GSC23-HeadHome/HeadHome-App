import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';
import 'package:headhome/api/models/caregiverdata.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/soslogdata.dart';
import 'package:headhome/api/models/travellogdata.dart';
import 'package:headhome/api/models/volunteerdata.dart';
import 'package:headhome/constants.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

/// Service class to interact with application backend.
class ApiService {
  // ---------- CARERECEIVER METHODS ----------

  /// Registers a new patient account.
  static Future<http.Response> createCarereceiver(
    String id,
    String name,
    String address,
    String contactNum,
  ) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}');

    Map data = {
      'CrId': id,
      'Name': name,
      'Address': address,
      'ContactNum': contactNum,
      'CareGiver': [],
    };

    // encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  /// Retrieves patient information.
  static Future<CarereceiverModel?> getCarereceiver(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id');
      var response = await http.get(url);
      debugPrint(response.body);
      if (response.statusCode == 200) {
        CarereceiverModel model = carereceiverFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  /// Updates patient information.
  static Future<http.Response> updateCarereceiver(String id, String name,
      String address, String contactNum, String cgId, String relation) async {
    Uri url =
        Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id');
    debugPrint(url.toString());
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
  
  /// Updates the safezone radius for a particular patient.
  static Future<http.Response> updateSafezoneRadius(String id, int radius) async {
    Uri url =
        Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id');
    debugPrint(url.toString());
    Map data = {
      'SafezoneRadius': radius,
    };

    var body = json.encode(data);

    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  /// For patient to send an SOS alert to caregivers.
  static Future<http.Response> requestHelp(
    String id,
    LatLng startPos,
    String endLat,
    String endLng,
  ) async {
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

  /// For patients to receive route back home.
  static Future<http.Response> routingHelp(
      LatLng startPos, String endLat, String endLng) async {
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

  /// Registers a new caregiver account.
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

  /// Retrieves caregiver information.
  static Future<CaregiverModel?> getCaregiver(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.caregiver}/$id');
      debugPrint(url.toString());
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

  /// Retrieves caregiver contact.
  static Future<Cgcontactnum?> getCgContact(String cgId, crId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'GET',
      Uri.parse('https://HeadHome.chayhuixiang.repl.co/carereceiver/contactcg'),
    );
    debugPrint("$cgId $crId");
    request.body = json.encode({"CrId": crId, "CgId": cgId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      Cgcontactnum model = cgcontactnumFromJson(res);
      return model;
    } else {
      debugPrint(response.reasonPhrase);
      return null;
    }
  }

  /// Updates patient information.
  static Future<UpdateCgResponse> updateCg(String contact, String cgId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('PUT',
        Uri.parse('https://HeadHome.chayhuixiang.repl.co/caregiver/$cgId'));
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

  /// Adds a new patient under the caregiver.
  static Future<AddPatientMessage> addPatient(
      String cgId, String crId, String relationship) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'PUT',
      Uri.parse('https://HeadHome.chayhuixiang.repl.co/caregiver/$cgId/newcr'),
    );
    request.body = json.encode({"Id": crId, "Relationship": relationship});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 202) {
      var res = await response.stream.bytesToString();
      AddPatientMessage model = addPatientMessageFromJson(res);
      debugPrint("alert sent");
      return model;
    } else {
      throw Exception('Failed to add patient: ${response.reasonPhrase}');
    }
  }

  // -------- END OF CAREGIVER METHODS ---------

  // ------------ VOLUNTEER METHODS ------------

  /// Registers a new volunteer account.
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

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  /// Retrieves volunteer information.
  static Future<VolunteerModel?> getVolunteer(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.volunteers}/$id');
      debugPrint(url.toString());
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

  /// Updates volunteer information.
  static Future<UpdateVolResponse> updateVolunteer(
      String contact, String vId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'PUT',
      Uri.parse('https://HeadHome.chayhuixiang.repl.co/volunteers/$vId'),
    );
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

  /// Authenticates a volunteer to guide a patient home.
  static Future<AcceptSOSResponse?> acceptSOS(
    String sosId,
    String authID,
    String vId,
  ) async {
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

  /// Retrieves information about particular sos call.
  static Future<SosLogModel?> getSOSLog(String id) async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.sos}/$id');
      debugPrint(url.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        SosLogModel model = sosLogModelFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  /// Updates information about a particular sos call.
  static Future<void> updateSOS(String id, String status) async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.sos}/$id');
      debugPrint('$url');
      await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"Status": status}),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  /// Sends SOS to volunteers near patient.
  static Future<SosMessage> sendSOS(String crId) async {
    final TravelLogModel? travelLogModel = await getTravelLog(crId);

    int datetime =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://HeadHome.chayhuixiang.repl.co/sos/'));
    request.body = json.encode({
      "CrId": crId,
      "Datetime": datetime,
      "StartLocation": {
        "Lat": travelLogModel?.currentLocation.lat,
        "Lng": travelLogModel?.currentLocation.lng,
      },
      "Status": "lost",
      "Volunteer": ""
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 202) {
      var res = await response.stream.bytesToString();
      SosMessage model = sosMessageFromJson(res);
      debugPrint("alert sent");
      return model;
    } else {
      throw Exception('Failed to send SOS: ${response.reasonPhrase}');
    }
  }

  // --------- END OF SOS LOG METHODS ----------

  // ----------- TRAVEL LOG METHODS ------------

  /// Uploads patient location onto cloud firestore.
  static Future<http.Response> updateCarereceiverLoc(
      String id, double lat, double lng, String status) async {
    int datetime =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    String travelLogId = id + datetime.toString();
    Uri url = Uri.parse(
        '${ApiConstants.baseUrl}/${ApiConstants.travellog}/$travelLogId');
    Map data = {
      "CrId": id,
      "Datetime": datetime,
      "CurrentLocation": {"Lat": lat, "Lng": lng},
      "Status": status,
    };

    var body = json.encode(data);

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    return response;
  }

  /// Retrieves patient location information.
  static Future<TravelLogModel?> getTravelLog(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.travellog}/$id');
      debugPrint(url.toString());
      var response = await http.get(url);
      if (response.statusCode == 200) {
        TravelLogModel model = travelLogModelFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  // --------- END OF TRAVEL LOG METHODS -------

  // --------- FIREBASE STORAGE METHODS --------

  /// Retrieves image in bytes from a firebase storage path.
  static Future<Uint8List?> getProfileImg(String imageName) async {
    Reference? storageRef = FirebaseStorage.instance.ref();
    final profileRef = storageRef.child("ProfileImg");

    if (imageName == "") return null;
    final imageRef = profileRef.child(imageName);
    try {
      const oneMegabyte = 4096 * 4096;
      return (await imageRef.getData(oneMegabyte));
    } on FirebaseException catch (_) {
      debugPrint("Error getting profile");
      return null;
    } catch (_) {
      return null;
    }
  }

  // ----- END OF FIREBASE STORAGE METHODS -----
}
