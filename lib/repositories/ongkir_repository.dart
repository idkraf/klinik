
import '../app_config.dart';
import '../data_model/ongkir_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OngkirRepo {

  Future<OngkirResponse> getOngkirResponse({
    origin = 501,
    destination = 574,
    weight = 1700,
    kurir = "jne"
  }) async {

    Uri url = Uri.parse("${AppConfig.BASE_URL}/ongkir?origin=${origin}&originType=city&destination=${destination}&destinationType=subdistrict&weight=${weight}&courier=${kurir}");
    print(url.toString());
    final response = await http.get(url);
    print(response.body.toString());
    return ongkirResponseFromJson(response.body);
  }
}