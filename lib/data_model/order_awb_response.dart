// To parse this JSON data, do
//
//     final orderItemlResponse = orderItemlResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

OrderAwbResponse orderAwbResponseFromJson(String? str) => OrderAwbResponse.fromJson(json.decode(str!));

String? orderAwbResponseToJson(OrderAwbResponse data) => json.encode(data.toJson());

class OrderAwbResponse {
  OrderAwbResponse({
    this.awb,
    this.deliveryInfo,
    this.success,
    this.status,
  });

  List<AwbItem>? awb;
  DeliveryInfo? deliveryInfo;
  bool? success;
  int? status;

  factory OrderAwbResponse.fromJson(Map<String, dynamic> json) => OrderAwbResponse(
    awb: List<AwbItem>.from(json["data"].map((x) => AwbItem.fromJson(x))),
    deliveryInfo: DeliveryInfo.fromJson(json['delivery']),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(awb!.map((x) => x.toJson())),
    "delivery": deliveryInfo,
    "success": success,
    "status": status,
  };
}

class AwbItem {
  AwbItem({
    this.manifest_code,
    this.manifest_description,
    this.manifest_date,
    this.manifest_time,
    this.city_name
  });

  int? manifest_code;
  String? manifest_description;
  String? manifest_date;
  String? manifest_time;
  String? city_name;


  factory AwbItem.fromJson(Map<String, dynamic> json) => AwbItem(
    manifest_code: json["manifest_code"],
    manifest_description: json["manifest_description"],
    manifest_date: json["manifest_date"],
    manifest_time: json["manifest_time"],
    city_name: json["city_name"],
  );

  Map<String, dynamic> toJson() => {
    "manifest_code" : manifest_code,
    "manifest_description" : manifest_description,
    "manifest_date" : manifest_date,
    "manifest_time" : manifest_time,
    "city_name" : city_name,
  };
}

class DeliveryInfo {
  DeliveryInfo({
    this.status,
    this.pod_receiver,
    this.pod_date,
    this.pod_time
  });
  String? status;
  String? pod_receiver;
  String? pod_date;
  String? pod_time;


  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => DeliveryInfo(
    status: json["status"],
    pod_receiver: json["pod_receiver"],
    pod_date: json["pod_date"],
    pod_time: json["pod_time"],
  );

  Map<String, dynamic> toJson() => {
    "status" : status,
    "pod_receiver" : pod_receiver,
    "pod_date" : pod_date,
    "pod_time" : pod_time,
  };
}
