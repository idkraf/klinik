import 'package:klinikkecantikan/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:klinikkecantikan/data_model/order_mini_response.dart';
import 'package:klinikkecantikan/data_model/order_detail_response.dart';
import 'package:klinikkecantikan/data_model/order_item_response.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';

import '../data_model/order_awb_response.dart';

class OrderRepository {
  Future<OrderMiniResponse> getOrderList(
      {page = 1, payment_status = "", delivery_status = ""}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/purchase-history" +
        "?page=${page}&payment_status=${payment_status}&delivery_status=${delivery_status}");
    print("url:" +url.toString());
    print("token:" +access_token.$);
    final response = await http.get(url,headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
        });

    print("res:${response.body}");
    return orderMiniResponseFromJson(response.body);
  }

  Future<OrderDetailResponse> getOrderDetails({int id = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/purchase-history-details/" + id.toString());

    final response = await http.get(url,headers: {
      "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$,
        });
    //print("url:" +url.toString());
    print("res:${response.body}");
    return orderDetailResponseFromJson(response.body);
  }

  Future<OrderItemResponse> getOrderItems({int id = 0}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/purchase-history-items/" + id.toString());
    final response = await http.get(url,headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
        });

    return orderItemlResponseFromJson(response.body);
  }

  //get tracking resi

  Future<OrderAwbResponse> getAwb({String kurir = "", String awb = ""}) async {
    Uri url = Uri.parse(
        "${AppConfig.BASE_URL}/awb?waybill=" + awb + "&courier=" + kurir);
    final response = await http.get(url,headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$,
    });

    return orderAwbResponseFromJson(response.body);
  }
}
