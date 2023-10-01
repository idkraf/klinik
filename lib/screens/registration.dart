import 'package:klinikkecantikan/app_config.dart';
import 'package:klinikkecantikan/custom/device_info.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/screens/common_webview_screen.dart';
import 'package:klinikkecantikan/ui_elements/auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klinikkecantikan/custom/input_decorations.dart';
import 'package:klinikkecantikan/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:klinikkecantikan/screens/login.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:klinikkecantikan/repositories/auth_repository.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:validators/validators.dart';

import '../helpers/auth_helper.dart';
import '../other_config.dart';
import '../repositories/profile_repository.dart';
import 'main.dart';


class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "email"; //phone or email
  String initialCountry = 'ID';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'ID', dialCode: "+62");

  String _phone = "";
  bool _isAgree =false;

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _referralController = TextEditingController();

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

  oncekReferral() async{
    var referral_by = _referralController.text.toString();
    if (referral_by == "") {
      ToastComponent.showDialog("Kode Referral tidak boleh kosong", gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var cekReferralResponse = await AuthRepository().cekReferralResponse(
        reff_id: referral_by
    );
    if (cekReferralResponse.result == false) {
      onPressSignUp(0);
    }else {
      print("cek referral id: ${cekReferralResponse.user_id!}");
      //if kode refferal terdaftar maka lanjutkan pendaftaran
      onPressSignUp(cekReferralResponse.user_id!);
    }
  }

  onPressSignUp(int referred) async {
    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var phone = _phoneNumberController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();
    var referral_by = referred != 0 ? referred : 0;

    if (name == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.registration_screen_name_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'email' &&( email == "" || !isEmail(email))) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.registration_screen_email_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.registration_screen_phone_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.registration_screen_password_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password_confirm == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.registration_screen_password_confirm_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.registration_screen_password_length_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.registration_screen_password_match_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var signupResponse = await AuthRepository().getSignupResponse(
        name,
        _register_by == 'email' ? email : _phone,
        password,
        password_confirm,
        _register_by,
        referral_by);

    if (signupResponse.result == false) {
      ToastComponent.showDialog(signupResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(signupResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
      if(mail_verification_status.$ && _register_by=="email") {
      //  Navigator.push(context, MaterialPageRoute(builder: (context) {
      //    return Otp(
      //      verify_by: _register_by,
      //      user_id: signupResponse.user_id,
      //    );
      //  }));
      }else{
        //Navigator.push(context, MaterialPageRoute(builder: (context) {
        //  return Login();
        // }));
        //buat langsung login
        var loginResponse = await AuthRepository()
            .getLoginResponse(_register_by == 'email' ? email : _phone, password);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(context,
        "${AppLocalizations.of(context)!.registration_screen_join} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
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
                          AppLocalizations.of(context)!.registration_screen_name,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 36,
                          child: TextField(
                            controller: _nameController,
                            autofocus: false,
                            decoration: InputDecorations.buildInputDecoration_1(
                                hint_text: "John Doe"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          _register_by == "email" ? AppLocalizations.of(context)!.registration_screen_email : AppLocalizations.of(context)!.registration_screen_phone,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_register_by == "email")
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
                                          _register_by = "phone";
                                        });
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.registration_screen_or_register_with_phone,
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
                                  initialValue: phoneCode,
                                  textFieldController: _phoneNumberController,
                                  formatInput: true,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  inputDecoration: InputDecorations
                                      .buildInputDecoration_phone(
                                          hint_text: "08XXX XXX XXXX"),
                                  onSaved: (PhoneNumber number) {
                                    //print('On Saved: $number');
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _register_by = "email";
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.registration_screen_or_register_with_email,
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
                          AppLocalizations.of(context)!.registration_screen_password,
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
                            Text(
                              AppLocalizations.of(context)!.registration_screen_password_length_recommendation,
                              style: TextStyle(
                                  color: MyTheme.textfield_grey,
                                  fontStyle: FontStyle.italic),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          AppLocalizations.of(context)!.registration_screen_retype_password,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 36,
                          child: TextField(
                            controller: _passwordConfirmController,
                            autofocus: false,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecorations.buildInputDecoration_1(
                                hint_text: "• • • • • • • •"),
                          ),
                        ),
                      ),
                      //referral
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "Kode referral",
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 36,
                          child: TextField(
                            controller: _referralController,
                            autofocus: false,
                            decoration: InputDecorations.buildInputDecoration_1(
                                hint_text: "Kode referral"),
                          ),
                        ),
                      ),
                      //end new referral
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 15,
                                width: 15,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    value: _isAgree, onChanged: (newValue){
                                    _isAgree = newValue!;
                                    setState((){});
                                }),),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                width: DeviceInfo(context).width!-180,
                                child: RichText(
                                  maxLines: 2,
                                    text: TextSpan(
                                  style: TextStyle(color: MyTheme.font_grey,fontSize: 12),
                                 children: [
                                   TextSpan(
                                    text: "I agree to the",
                                   ),

                                   TextSpan(
                                     recognizer: TapGestureRecognizer()..onTap=(){
                                       Navigator.push(context, MaterialPageRoute(builder: (context)=>CommonWebviewScreen(page_name: "Terms Conditions",url: "${AppConfig.RAW_BASE_URL}/mobile-page/terms",)));

                                     },
                                       style: TextStyle(color: MyTheme.accent_color),
                                    text: " Terms Conditions",
                                   ),
                                   TextSpan(
                                    text: " &",
                                   ),
                                   TextSpan(
                                       recognizer: TapGestureRecognizer()..onTap=(){
                                         Navigator.push(context, MaterialPageRoute(builder: (context)=>CommonWebviewScreen(page_name: "Privacy Policy",url: "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",)));


                                       },
                                    text: " Privacy Policy",
                                       style: TextStyle(color: MyTheme.accent_color),

                                   )
                                 ]
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Container(
                          height: 45,
                          child: TextButton(
                          style: TextButton.styleFrom(
                            //minWidth: MediaQuery.of(context).size.width,
                            disabledBackgroundColor: MyTheme.grey_153,
                            //height: 50,
                            backgroundColor: MyTheme.accent_color,
                            shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(6.0)))),
                            child: Text(
                              AppLocalizations.of(context)!.registration_screen_register_sign_up,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: _isAgree? () {
                                if (_referralController.text.toString().isNotEmpty) {
                                  print("cek referral: ${_referralController.text.toString()}");
                                  oncekReferral();
                                }else{
                                  onPressSignUp(0);
                                }
                            }:null,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: Text(
                                  AppLocalizations.of(context)!.registration_screen_already_have_account,
                              style: TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12),
                            )),
                            SizedBox(width: 10,),

                            InkWell(
                              child: Text(
                                AppLocalizations.of(context)!.registration_screen_log_in,
                                style: TextStyle(
                                    color:MyTheme.accent_color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Login();
                                }));
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
  }
}
