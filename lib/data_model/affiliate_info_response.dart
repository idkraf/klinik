// To parse this JSON data, do
//
//     final clubpointResponse = clubpointResponseFromJson(jsonString);

import 'dart:convert';

AffiliateInfoResponse affiliateInfoResponseFromJson(String? str) => AffiliateInfoResponse.fromJson(json.decode(str!));

String? affiliateInfoResponseToJson(AffiliateInfoResponse data) => json.encode(data.toJson());

class AffiliateInfoResponse {
  AffiliateInfoResponse({
    this.success,
    this.numberklik,
    this.numberitem,
    this.numberdelivered,
    this.numbercancel,
    this.balance,
    this.bank,
    this.status,
  });

  bool? success;
  int? numberklik;
  int? numberitem;
  int? numberdelivered;
  int? numbercancel;
  int? balance;
  String? bank;
  int? status;

  factory AffiliateInfoResponse.fromJson(Map<String, dynamic> json) => AffiliateInfoResponse(
    numberklik: json["numberklik"],
    numberitem: json["numberitem"],
    numberdelivered: json["numberdelivered"],
    numbercancel: json["numbercancel"],
    balance: json["balance"],
    success: json["success"],
    bank: json["bank"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "numberklik": numberklik,
    "numberitem": numberitem,
    "numberdelivered": numberdelivered,
    "numbercancel": numbercancel,
    "balance": balance,
    "bank": bank,
    "success": success,
    "status": status,
  };
}