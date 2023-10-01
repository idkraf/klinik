// To parse this JSON data, do
//
//     final walletBalanceResponse = walletBalanceResponseFromJson(jsonString);
//https://app.quicktype.io/

import 'dart:convert';

WalletBalanceResponse walletBalanceResponseFromJson(String? str) => WalletBalanceResponse.fromJson(json.decode(str!));

String? walletBalanceResponseToJson(WalletBalanceResponse data) => json.encode(data.toJson());

class WalletBalanceResponse {
  WalletBalanceResponse({
    this.balance,
    this.saldo,
    this.last_recharged,
  });

  String? balance;
  int? saldo;
  String? last_recharged;

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) => WalletBalanceResponse(
    balance: json["balance"],
    saldo: json["saldo"],
    last_recharged: json["last_recharged"],
  );

  Map<String, dynamic> toJson() => {
    "balance": balance,
    "saldo": saldo,
    "last_recharged": last_recharged,
  };
}