import 'dart:convert';

KabupatenResponse kabupatenResponseFromJson(String str) => KabupatenResponse.fromJson(json.decode(str));

String kabupatenResponseToJson(KabupatenResponse data) => json.encode(data.toJson());

class KabupatenResponse {
  KabupatenResponse({
    this.states,
    this.status,
  });

  List<KabupatenModel>? states;
  int? status;

  factory KabupatenResponse.fromJson(Map<String, dynamic> json) => KabupatenResponse(
    states: List<KabupatenModel>.from(json["data"].map((x) =>KabupatenModel.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(states!.map((x) => x.toJson())),
    "status": status,
  };
}

class KabupatenModel {
  KabupatenModel({
    required this.cityId,
    required this.provinceId,
    required this.province,
    required this.type,
    required this.cityName,
    required this.postalCode,
  });

  String cityId;
  String provinceId;
  String province;
  String type;
  String cityName;
  String postalCode;

  factory KabupatenModel.fromJson(Map<String, dynamic> json) => KabupatenModel(
    cityId: json["city_id"],
    provinceId: json["province_id"],
    province: json["province"],
    type: json["type"],
    cityName: json["city_name"],
    postalCode: json["postal_code"],
  );

  Map<String, dynamic> toJson() => {
    "city_id": cityId,
    "province_id": provinceId,
    "province": province,
    "type": type,
    "city_name": cityName,
    "postal_code": postalCode,
  };
}