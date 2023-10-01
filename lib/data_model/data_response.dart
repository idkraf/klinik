// To parse this JSON data, do
//
//     final logoutResponse = logoutResponseFromJson(jsonString);

import 'dart:convert';

DataResponse dataResponseFromJson(String? str) => DataResponse.fromJson(json.decode(str!));

String? dataResponseToJson(DataResponse data) => json.encode(data.toJson());

class DataResponse {
  DataResponse({
    this.result,
    this.message,
  });

  bool? result;
  String? message;

  factory DataResponse.fromJson(Map<String, dynamic> json) => DataResponse(
    result: json["result"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "message": message,
  };
}