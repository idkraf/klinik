import 'dart:convert';

OngkirResponse ongkirResponseFromJson(String str) => OngkirResponse.fromJson(json.decode(str));

String ongkirResponseToJson(OngkirResponse data) => json.encode(data.toJson());

class OngkirResponse {
  OngkirResponse({
    this.data,
    this.status,
  });

  List<CourierServiceModel>? data;
  int? status;

  factory OngkirResponse.fromJson(Map<String, dynamic> json) => OngkirResponse(
    data: List<CourierServiceModel>.from(json["data"].map((x) =>CourierServiceModel.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
  };
}

class CourierServiceModel {
  CourierServiceModel({
    required this.service,
    required this.description,
    required this.cost,
  });

  String service;
  String description;
  List<Cost> cost;

  factory CourierServiceModel.fromJson(Map<String, dynamic> json) => CourierServiceModel(
    service: json["service"],
    description: json["description"],
    cost: List<Cost>.from(json["cost"].map((x) => Cost.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "service": service,
    "description": description,
    "cost": List<dynamic>.from(cost.map((x) => x.toJson())),
  };
}

class Cost {
  Cost({
    required this.value,
    required this.etd,
    required this.note,
  });

  int value;
  String etd;
  String note;

  factory Cost.fromJson(Map<String, dynamic> json) => Cost(
    value: json["value"],
    etd: json["etd"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "etd": etd,
    "note": note,
  };
}