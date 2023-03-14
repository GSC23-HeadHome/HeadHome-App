import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:http/http.dart' as http;
import 'package:headhome/constants.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';

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

  static Future<Carereceiver?> getCarereceiver(String id) async {
    try {
      var url =
          Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/$id');
      print(url);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Carereceiver model = carereceiverFromJson(response.body);
        return model;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
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
  // -------- END OF CAREGIVER METHODS ---------

  // ------------ VOLUNTEER METHODS ------------
  static Future<http.Response> createVolunteer(
      String id, String name, String contactNum) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.caregiver}');

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

  // -------- END OF VOLUNTEER METHODS ---------
}
