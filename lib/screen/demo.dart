import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';

class Demo extends StatefulWidget {
  @override
  _Demo createState() => _Demo();
}

class _Demo extends State<Demo> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  double heigntValue = 300;
  bool full = true;
  bool full1 = false;
  bool vi_address = true;
  int _radioValue = -1;
  String _result = "0";

  String driver_address = "Not Found";

  String? id;
  String? orderId;
  String? vendorname;
  String? vendorAddress;
  String? distance;

  Timer? timer;

  int second = 10;
  double? current_lat;
  double? current_lang;

  void _handleRadioValueChange(int value) {
    if (mounted) {
      setState(() {
        _radioValue = value;

        switch (_radioValue) {
          case 0:
            _result = "0";
            break;
          case 1:
            _result = "1";
            break;
          case 2:
            _result = "2";

            // setstripe(context,_result);
            break;
          case 3:
            _result = "3";
            break;
          case 4:
            _result = "4";
            break;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    second = int.parse(PreferenceUtils.getString(Constants.driver_auto_refrese));
    print("Seconds:${PreferenceUtils.getString(Constants.driver_auto_refrese)}");
    print("currentlat:${Constants.currentlat}");
    print("currentlong:${Constants.currentlong}");
    if (Constants.currentlat != 0.0 && Constants.currentlong != 0.0) {
      setState(() {
        Constants.CheckNetwork().whenComplete(() => timer = Timer.periodic(
            Duration(seconds: second),
            (Timer t) => PostDriverLocation(
                Constants.currentlat, Constants.currentlong)));
      });
    } else {
      setState(() {
        checkforpermission();
        print("checkpermission123");
      });

      // Constants.currentlatlong().whenComplete(() => Constants.currentlatlong().then((value){print("origin123:$value");}));

    }

    PreferenceUtils.init();

    if (mounted) {
      setState(() {
        orderId = PreferenceUtils.getString(Constants.previos_order_orderid);
        vendorname =
            PreferenceUtils.getString(Constants.previos_order_vendor_name);
        vendorAddress =
            PreferenceUtils.getString(Constants.previos_order_vendor_address);
        distance = PreferenceUtils.getString(Constants.previos_order_distance);
      });
    }

    setState(() {
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {
                driver_address = value;
                print("driver_address:$driver_address");
              }));
    });
  }

  void checkforpermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("denied");
      Constants.createSnackBar(
          "Allow location", context, Color(Constants.redtext));
    } else if (permission == LocationPermission.whileInUse) {
      print("whileInUse56362");

      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                current_lat = value!.latitude;
                current_lang = value.longitude;
              }));
      Constants.CheckNetwork()
          .whenComplete(() => PostDriverLocation(current_lang, current_lang));
    } else if (permission == LocationPermission.always) {
      print("always");

      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                print("origin123:$value");
              }));
      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                current_lat = value!.latitude;
                current_lang = value.longitude;
              }));
      Constants.CheckNetwork()
          .whenComplete(() => PostDriverLocation(current_lang, current_lang));
    }
  }

  void PostDriverLocation(double? currentlat, double? currentlang) {
    print("UpdateLat:$currentlat");
    print("UpdateLang:$currentlang");
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenheight = MediaQuery.of(context).size.height;
    dynamic screenwidth = MediaQuery.of(context).size.width;

   /* ScreenUtil.init(context,
        designSize: Size(screenwidth, screenheight), allowFontScaling: true);
*/
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/background_image.png'),
            fit: BoxFit.cover,
          )),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              // resizeToAvoidBottomPadding: false,
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              body: new Container(
                alignment: Alignment.center,
                height: 200,
                width: 200,
                color: Colors.white,
                child: Center(
                  child: Text("update"),
                ),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }
}
