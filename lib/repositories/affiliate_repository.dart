import 'package:klinikkecantikan/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';

import '../data_model/affiliate_info_response.dart';
import '../data_model/affiliate_response.dart';
import '../data_model/data_response.dart';

class AffiliateRepository {

  Future<AffiliateResponse> getAffiliateResponse(
      {page = 1}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/affiliate/get-list?page=$page");
    print("url(${url.toString()}) access token (Bearer ${access_token.$})");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$
      },
    );
    // print(response.body.toString());
    return affiliateResponseFromJson(response.body);
  }

  //get info point, info referal lainnya
  Future<AffiliateInfoResponse> getAffiliateInfoResponse(
      {type = "Today"}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/affiliate/get-info?type=$type");
    print("url(${url.toString()}) access token (Bearer ${access_token.$})");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$
      },
    );
    // print(response.body.toString());
    return affiliateInfoResponseFromJson(response.body);
  }

  //withdraw poin
  Future<DataResponse> updateWithdrawalResponse(
      {amount = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/affiliate/withdrawal?amount=$amount");
    print("url(${url.toString()}) access token (Bearer ${access_token.$})");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$
      },
    );
    // print(response.body.toString());
    return dataResponseFromJson(response.body);
  }

  //add bank payout
  Future<DataResponse> updateInfoPayoutResponse(
      {bank = ""}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/affiliate/payout?bank=$bank");
    print("url(${url.toString()}) access token (Bearer ${access_token.$})");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$
      },
    );
    // print(response.body.toString());
    return dataResponseFromJson(response.body);
  }


}
