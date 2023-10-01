import 'dart:convert';
import 'package:klinikkecantikan/repositories/ongkir_repository.dart';
import 'package:get/get.dart';

import '../controller/ongkir_controller.dart';

Future<Map<String, Map<String, String>>> init() async {

  Get.lazyPut(() => OngkirRepo());
  Get.lazyPut(() => OngkirController(ongkirRepo: Get.find()));

  Map<String, Map<String, String>> _di = Map();
  return _di;
}