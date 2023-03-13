// To parse this JSON data, do
//
//     final cgcontactnum = cgcontactnumFromJson(jsonString);

import 'dart:convert';

Cgcontactnum cgcontactnumFromJson(String str) => Cgcontactnum.fromJson(json.decode(str));

String cgcontactnumToJson(Cgcontactnum data) => json.encode(data.toJson());

class Cgcontactnum {
    Cgcontactnum({
        required this.cgContactNum,
    });

    String cgContactNum;

    factory Cgcontactnum.fromJson(Map<String, dynamic> json) => Cgcontactnum(
        cgContactNum: json["CgContactNum"],
    );

    Map<String, dynamic> toJson() => {
        "CgContactNum": cgContactNum,
    };
}
