import 'package:flutter/material.dart';

var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text = "@ Klinik " + this_year; //this shows in the splash screen
  static String app_name = "Klinik"; //this shows in the splash screen


  //Default language config
  static String default_language = "id";
  static String mobile_app_code = "id";
  static bool app_language_rtl = false;

  //configure this
  static const bool HTTPS = true;

  //configure this
  static const DOMAIN_PATH = "klinik.rumahbejo.com"; // directly inside the public folder
  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";

}
