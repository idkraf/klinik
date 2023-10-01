import 'dart:convert';

ProvinceResponse provinceResponseFromJson(String str) => ProvinceResponse.fromJson(json.decode(str));

String provinceResponseToJson(ProvinceResponse data) => json.encode(data.toJson());

class ProvinceResponse {
  ProvinceResponse({
    this.states,
    this.status,
  });

  List<ProvinceModel>? states;
  int? status;

  factory ProvinceResponse.fromJson(Map<String, dynamic> json) => ProvinceResponse(
    states: List<ProvinceModel>.from(json["data"].map((x) => ProvinceModel.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(states!.map((x) => x.toJson())),
    "status": status,
  };
}

class ProvinceModel {
  ProvinceModel({
    required this.provinceId,
    required this.province,
  });

  String provinceId;
  String province;

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
    provinceId: json["province_id"],
    province: json["province"],
  );

  Map<String, dynamic> toJson() => {
    "province_id": provinceId,
    "province": province,
  };
}