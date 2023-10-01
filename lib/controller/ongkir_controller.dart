import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data_model/ongkir_response.dart';
import '../repositories/ongkir_repository.dart';

class OngkirController extends GetxController implements GetxService {
  final OngkirRepo ongkirRepo;
  OngkirController({required this.ongkirRepo});

  Future<OngkirResponse> cekongkir(origin,destination,weight,kurir) async {
    print("cek ongkir: $origin - $destination - $weight - $kurir");
    OngkirResponse response = await ongkirRepo.getOngkirResponse(origin: origin,destination: destination, weight: weight, kurir: kurir);
    return response;
  }

}