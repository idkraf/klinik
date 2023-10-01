import 'package:klinikkecantikan/app_config.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/other_config.dart';
import 'package:klinikkecantikan/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klinikkecantikan/custom/input_decorations.dart';
import 'package:klinikkecantikan/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:klinikkecantikan/screens/registration.dart';
import 'package:klinikkecantikan/screens/main.dart';
import 'package:klinikkecantikan/screens/password_forget.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:klinikkecantikan/repositories/auth_repository.dart';
import 'package:klinikkecantikan/helpers/auth_helper.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:klinikkecantikan/repositories/profile_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  String _phone = "";

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.login_screen_email_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.login_screen_phone_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.login_screen_password_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);
    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
    } else {

      ToastComponent.showDialog(loginResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
      AuthHelper().setUserData(loginResponse);
      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;

        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String? fcmToken = await _fcm.getToken();

        if (fcmToken != null) {
          print("--fcm token--");
          print(fcmToken);
          if (is_logged_in.$ == true) {
            // update device token
            var deviceTokenUpdateResponse = await ProfileRepository()
                .getDeviceTokenUpdateResponse(fcmToken);
          }
        }
      }

      //push norification ends

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(context,"${AppLocalizations.of(context)!.login_screen_login_to} " + AppConfig.app_name ,buildBody(context, _screen_width));

  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: _screen_width * (3 / 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          _login_by == "email" ? AppLocalizations.of(context)!.login_screen_email : AppLocalizations.of(context)!.login_screen_phone,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_login_by == "email")
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 36,
                                child: TextField(
                                  controller: _emailController,
                                  autofocus: false,
                                  decoration:
                                      InputDecorations.buildInputDecoration_1(
                                          hint_text: "johndoe@example.com"),
                                ),
                              ),
                              otp_addon_installed.$
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _login_by = "phone";
                                        });
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.login_screen_or_login_with_phone,
                                        style: TextStyle(
                                            color: MyTheme.accent_color,
                                            fontStyle: FontStyle.italic,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 36,
                                child: CustomInternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    print(number.phoneNumber);
                                    setState(() {
                                      _phone = number.phoneNumber!;
                                    });
                                  },
                                  onInputValidated: (bool value) {
                                    print(value);
                                  },
                                  selectorConfig: SelectorConfig(
                                    selectorType: PhoneInputSelectorType.DIALOG,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle:
                                      TextStyle(color: MyTheme.font_grey),
                                  textStyle:
                                      TextStyle(color: MyTheme.font_grey),
                                  initialValue: phoneCode,
                                  textFieldController: _phoneNumberController,
                                  formatInput: true,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  inputDecoration: InputDecorations
                                      .buildInputDecoration_phone(
                                          hint_text: "01XXX XXX XXX"),
                                  onSaved: (PhoneNumber number) {
                                    print('On Saved: $number');
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _login_by = "email";
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.login_screen_or_login_with_email,
                                  style: TextStyle(
                                      color: MyTheme.accent_color,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline),
                                ),
                              )
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          AppLocalizations.of(context)!.login_screen_password,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              child: TextField(
                                controller: _passwordController,
                                autofocus: false,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration:
                                    InputDecorations.buildInputDecoration_1(
                                        hint_text: "• • • • • • • •"),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return PasswordForget();
                                }));
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.login_screen_forgot_password,
                                style: TextStyle(
                                    color: MyTheme.accent_color,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: MyTheme.textfield_grey, width: 1),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize:  Size(MediaQuery.of(context).size.width, 50),
                              backgroundColor: MyTheme.accent_color,
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6.0))),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.login_screen_log_in,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              onPressedLogin();
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0,bottom: 15),
                        child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.login_screen_or_create_new_account,
                          style: TextStyle(
                              color: MyTheme.font_grey, fontSize: 12),
                        )),
                      ),
                      Container(
                        height: 45,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize:  Size(MediaQuery.of(context).size.width, 50),
                            backgroundColor: MyTheme.amber,
                            shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(6.0))),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.login_screen_sign_up,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Registration();
                            }));
                          },
                        ),
                      ),
                      Visibility(
                        visible: allow_google_login.$ ||
                            allow_facebook_login.$,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.login_screen_login_with,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12),
                          )),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
  }
}
