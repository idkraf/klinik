// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

CekReferralResponse cekReferralResponseFromJson(String? str) => CekReferralResponse.fromJson(json.decode(str!));

String? cekReferralResponseToJson(CekReferralResponse data) => json.encode(data.toJson());

class CekReferralResponse {
  CekReferralResponse({
    this.result,
    this.message,
    this.user_id,
  });

  bool? result;
  String? message;
  int? user_id;

  factory CekReferralResponse.fromJson(Map<String, dynamic> json) => CekReferralResponse(
    result: json["result"],
    message: json["message"],
    user_id: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "message": message,
    "user_id": user_id,
  };
}