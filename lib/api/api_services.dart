import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:headhome/constants.dart';
import 'package:headhome/api/models/carereceiverdata.dart';
import 'package:headhome/api/models/caregivercontactmodel.dart';

class ApiService {
  Future<Carereceiver?> getUser(String id) async {
    try {
      var url = Uri.parse(
          '${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/' + id);
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

  Future<Cgcontactnum?> getCgContact(String cgId, crId) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'GET',
        Uri.parse(
            '${ApiConstants.baseUrl}/${ApiConstants.carereceiver}/${ApiConstants.contactcg}'));
    request.body = json.encode({"CrId": crId, "CgId": cgId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      Cgcontactnum model = cgcontactnumFromJson(res);
      return model;
    } else {
      print(response.reasonPhrase);
    }

    // print(crId);
    // try {
    //   final queryParameters = json.encode({
    //     "CrId": "cr0001",
    //     "CgId": "cg0002",
    //   });
    //   final uri = Uri.http(
    //       ApiConstants.baseUrl, '/carereceiver/contactcg', queryParameters);
    //   final headers = {'Content-Type': 'application/json'};
    //   var response = await http.get(uri, headers: headers);

    //   if (response.statusCode == 200) {
    //     Cgcontactnum model = cgcontactnumFromJson(response.body);
    //     return model;
    //   }
    // } catch (e) {
    //   log(e.toString());
    // }
    // return null;
  }
}
