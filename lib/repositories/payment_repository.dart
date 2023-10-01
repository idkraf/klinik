import 'package:klinikkecantikan/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:klinikkecantikan/data_model/order_create_response.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';

import '../data_model/payment_type_response.dart';

class PaymentRepository {
  Future<List<PaymentTypeResponse>> getPaymentResponseList(
      {mode = "", list = "both"}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/payment-types?mode=${mode}&list=${list}");

    print("getPaymentResponseList url " + url.toString());

    final response = await http.get(url, headers: {
      "App-Language": app_language.$,
    });

    print("getPaymentResponseList" + response.body);

    return paymentTypeResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponse(
      payment_method) async {
    var post_body = jsonEncode({"payment_type": "${payment_method}"});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/order/store");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$,
        },
        body: post_body);
    return orderCreateResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponseFromWallet(
      payment_method, double amount, payment_name) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/payments/pay/wallet");

    var post_body = jsonEncode({
      "user_id": "${user_id.$}",
      "payment_type": "${payment_method}",
      "amount": "${amount}",
      "payment_name": "${payment_name}",
    });

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);

    //print(response.body.toString());
    return orderCreateResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponseFromCod(
      payment_method, payment_name) async {
    var post_body = jsonEncode({
          "user_id": "${user_id.$}",
          "payment_type": "${payment_method}",
          "payment_name": "${payment_name}",
        });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/payments/pay/cod");

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}"
        },
        body: post_body);

    //print(response.body.toString());
    return orderCreateResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponseFromManualPayment(
      payment_method, payment_name, payment_data) async {
    var post_body = jsonEncode({
      "user_id": "${user_id.$}",
      "payment_type": "${payment_method}",
      "payment_name": "${payment_name}",
      "payment_data": "${payment_data}"
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/payments/pay/manual");

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);

    //print(response.body.toString());
    return orderCreateResponseFromJson(response.body);
  }

}
