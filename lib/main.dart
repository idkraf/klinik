import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:klinikkecantikan/providers/locale_provider.dart';
import 'package:klinikkecantikan/screens/Splash.dart';
import 'package:klinikkecantikan/helpers/get_di.dart' as di;
import 'package:klinikkecantikan/services/push_notification_service.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:shared_value/shared_value.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_config.dart';
import 'lang_config.dart';
import 'my_theme.dart';
import 'other_config.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await di.init();
  runApp(
      SharedValue.wrapApp(MyApp())
  );
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero).then((value) async{

      Firebase.initializeApp().then((value){
        if (OtherConfig.USE_PUSH_NOTIFICATION) {
          Future.delayed(Duration(milliseconds: 10), () async {
            PushNotificationService().initialise();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers:[ChangeNotifierProvider(create: (_) => LocaleProvider()),],
    child:Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
      return MaterialApp(
        builder: OneContext().builder,
        navigatorKey: OneContext().navigator.key,
        title: AppConfig.app_name,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          //primarySwatch: Colors.blue,
          primaryColor: MyTheme.white,
          scaffoldBackgroundColor: MyTheme.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          hintColor: MyTheme.accent_color,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        locale: provider.locale,
        supportedLocales: LangConfig().supportedLocales(),
        home:  const Splash(),
      );
    }));
  }

}

