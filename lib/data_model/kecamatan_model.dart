import 'dart:convert';

KecamatanResponse kecamatanResponseFromJson(String str) => KecamatanResponse.fromJson(json.decode(str));

String kecamatanResponseToJson(KecamatanResponse data) => json.encode(data.toJson());

class KecamatanResponse {

  KecamatanResponse({
    this.states,
    this.status,
  });

  List<KecamatanModel>? states;
  int? status;

  factory KecamatanResponse.fromJson(Map<String, dynamic> json) => KecamatanResponse(
    states: List<KecamatanModel>.from(json["data"].map((x) => KecamatanModel.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(states!.map((x) => x.toJson())),
    "status": status,
  };

}


class KecamatanModel {
  KecamatanModel({
    required this.subdistrictId,
    required this.provinceId,
    required this.province,
    required this.cityId,
    required this.city,
    required this.type,
    required this.subdistrictName,
  });

  String subdistrictId;
  String provinceId;
  String province;
  String cityId;
  String city;
  String type;
  String subdistrictName;

  factory KecamatanModel.fromJson(Map<String, dynamic> json) => KecamatanModel(
    subdistrictId: json["subdistrict_id"],
    provinceId: json["province_id"],
    province: json["province"],
    cityId: json["city_id"],
    city: json["city"],
    type: json["type"],
    subdistrictName: json["subdistrict_name"],
  );

  Map<String, dynamic> toJson() => {
    "subdistrict_id": subdistrictId,
    "province_id": provinceId,
    "province": province,
    "city_id": cityId,
    "city": city,
    "type": type,
    "subdistrict_name": subdistrictName,
  };
}
