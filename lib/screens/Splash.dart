import 'dart:async';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/screens/Home.dart';
import 'package:klinikkecantikan/custom/text_widget.dart';
import 'package:package_info/package_info.dart';
import '../custom/device_info.dart';
//import '../helpers/addons_helper.dart';
import '../helpers/auth_helper.dart';
import '../helpers/business_setting_helper.dart';
import '../helpers/shared_value_helper.dart';
import '../my_theme.dart';
import '../providers/locale_provider.dart';
import '../screens/main.dart';
import 'package:provider/provider.dart';
import '../app_config.dart';
class Splash extends StatefulWidget
{
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  bool position=false;
  var opacity=0.0;

  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPackageInfo();
    Future.delayed(Duration.zero,(){
      animator();
    });
  }
  animator() async
  {

    if(opacity==0)
    {
      opacity=1;
      position=true;
    }
    else
    {
      opacity=0;
      position=false;
    }

    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<String>(
        future: getSharedValueHelperData(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Future.delayed(const Duration(seconds: 3)).then((value) {
              Provider.of<LocaleProvider>(context,listen: false).setLocale(app_mobile_language.$);
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
                  return Main(go_back: false,);
                },
                ),(route)=>false,);
            }
            );

          }
          return splashScreen();
        }
    );
  }

  Widget splashScreen() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
          color: Colors.white
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            top: position?60:150,
            left: 20,
            right: 20,
            child:  AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  TextWidget("Complete", 35, Colors.black, FontWeight.bold,letterSpace: 5,),
                  const SizedBox(height: 5,),
                  TextWidget("Health", 35, Colors.black, FontWeight.bold, letterSpace:  5,),
                  const SizedBox(height: 5,),
                  TextWidget("Solution", 35, Colors.black, FontWeight.bold,letterSpace: 5,),
                  const SizedBox(height: 20,),
                  TextWidget("Early Protection for\nFamily Health", 18, Colors.black.withOpacity(.7), FontWeight.bold),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
              bottom: 1,
              left: position?50:150, duration: const Duration(milliseconds: 400),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: opacity,
                child: Container(
                  height: 450,
                  width: 400,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/doctor6.png'),
                          fit: BoxFit.fill
                      )
                  ),
                ),
              )),
          AnimatedPositioned(
              bottom: 60,
              duration: const Duration(milliseconds: 400),
              left: position?20:-100,
              child: InkWell(
                onTap: ()
                {
                  position=false;
                  opacity=0;
                  setState(() {
                  });
                  Timer(const Duration(milliseconds: 400),() {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(),));
                  },);
                },
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    width: 150,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child:  TextWidget("Get Started", 17, Colors.white, FontWeight.bold,letterSpace: 0,),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Future<String>  getSharedValueHelperData()async{
    access_token.load().whenComplete(() {
      AuthHelper().fetch_and_set();
    });
    //AddonsHelper().setAddonsData();
    BusinessSettingHelper().setBusinessSettingData();
    await app_language.load();
    await app_mobile_language.load();
    await app_language_rtl.load();

    // print("new splash screen ${app_mobile_language.$}");
    // print("new splash screen app_language_rtl ${app_language_rtl.$}");

    return app_mobile_language.$;

  }
}