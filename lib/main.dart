import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mealup_driver/apiservice/Api_Header.dart';
import 'package:mealup_driver/apiservice/Apiservice.dart';
import 'package:mealup_driver/screen/homescreen.dart';
import 'package:mealup_driver/screen/login_screen.dart';
import 'package:mealup_driver/screen/otp_screen.dart';
import 'package:mealup_driver/screen/selectlocationscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'localization/locale_constant.dart';
import 'localization/localizations_delegate.dart';

void main() {
  //SdkContext.init(IsolateOrigin.main);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black, // status bar color
  ));
  PreferenceUtils.init();

  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
    supportedLocales: [
      Locale('en', ''),
      Locale('es', ''),
      Locale('ar', ''),
      /* Locale('hi', ''),*/
    ],
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    localeResolutionCallback: (locale, supportedLocales) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale?.languageCode &&
            supportedLocale.countryCode == locale?.countryCode) {
          return supportedLocale;
        }
      }
      return supportedLocales.first;
    },
  ));
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    PreferenceUtils.putBool(Constants.isGlobalDriver, false);
    super.initState();
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      title: 'Multi Language',
      locale: _locale,
      home: SplashScreen(),
      supportedLocales: [
        Locale('en', ''),
        Locale('es', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    print("navigation");

    if (PreferenceUtils.getlogin(Constants.isLoggedIn) == true) {
      if (PreferenceUtils.getverify(Constants.isverified) == true) {
        if (PreferenceUtils.getString(Constants.driverdeliveryzoneid)
                .toString() ==
            "0") {
          print("doc true");
          // go to set location screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectLocation()),
          );
        } else {
          // go to home screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(0)),
          );
        }
      } else {
        //go to verify
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => new OTPScreen()));
      }
    } else {
      // go to login

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => new LoginScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();

    checkforpermission();

    if (mounted) {
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          Constants.CheckNetwork().whenComplete(() => callApiForsetting());
        });
      });
    }
  }

  void checkforpermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("denied");
    } else if (permission == LocationPermission.whileInUse) {
      print("whileInUse56362");
      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                print("origin123:$value");
              }));
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {}));
    } else if (permission == LocationPermission.always) {
      print("always");
      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                print("origin123:$value");
              }));
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenheight = MediaQuery.of(context).size.height;
    dynamic screenwidth = MediaQuery.of(context).size.width;

    // ScreenUtil.init(context, designSize: Size(screenwidth, screenheight), allowFontScaling: true);
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new SafeArea(
          child: Scaffold(
            body: new Container(
              width: screenwidth,
              height: screenheight,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/background_image.png'),
                fit: BoxFit.cover,
              )),
              alignment: Alignment.center,
              child: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "images/main_logo.svg",
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setHeight(40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callApiForsetting() {
    RestClient(Api_Header().Dio_Data()).driversetting().then((response) {
      if (response.success == true) {
        print("Setting true");

        PreferenceUtils.setString(
            Constants.driversetvehicaltype, response.data!.driverVehicalType!);
        PreferenceUtils.setString(Constants.is_driver_accept_multipleorder,
            response.data!.isDriverAcceptMultipleorder.toString());
        PreferenceUtils.setString(Constants.driver_accept_multiple_order_count,
            response.data!.driverAcceptMultipleOrderCount.toString());
        PreferenceUtils.setString(Constants.driver_auto_refrese,
            response.data!.driverAutoRefrese.toString());
        PreferenceUtils.setString(
            Constants.one_signal_app_id, response.data!.driverAppId.toString());
        PreferenceUtils.setString(
            Constants.cancel_reason, response.data!.cancelReason!);
        print(PreferenceUtils.getString(
            Constants.is_driver_accept_multipleorder));
        print(PreferenceUtils.getString(Constants.driversetvehicaltype));
        print("Vehicletype:${response.data!.driverVehicalType}");

        if (PreferenceUtils.getString(Constants.one_signal_app_id).isNotEmpty) {
          getDeviceToken(
              PreferenceUtils.getString(Constants.one_signal_app_id));
        }

        startTime();
      } else {
        startTime();
      }
    }).catchError((obj) {
      print("error:$obj.");
      print(obj.runtimeType);

      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response!;
          print(res);
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
          }

          break;
        default:
      }
    });
  }

  void getDeviceToken(String appId) async {
    if (!mounted) return;
    print("AppId123:$appId");
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();

    await OneSignal.shared.getDeviceState().then((value) => {
          PreferenceUtils.setString(Constants.driverdevicetoken, value!.userId!)
        });

    print(
        '========= ${PreferenceUtils.getString(Constants.driverdevicetoken)}');
  }
}
