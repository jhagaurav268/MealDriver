import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
/*import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';*/
import 'package:mealup_driver/apiservice/Api_Header.dart';
import 'package:mealup_driver/apiservice/Apiservice.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/orderdeliverdscreen.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';

class PickUpOrder extends StatefulWidget {
  @override
  _PickUpOrder createState() => _PickUpOrder();
}

class _PickUpOrder extends State<PickUpOrder> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  double heigntValue = 300;
  bool vi_footer = true;
  bool vi_combtn = false;
  bool vi_address = true;
  bool showSpinner = false;
  String driver_address = "Not Found";
  String? id;
  late String orderId;
  late String vendorname;
  late String vendorAddress;
  String? distance;
  late String username;
  String user_distance = "0";
  late String useraddress;

  Timer? timer;

  int second = 10;
  double? driver_lat;
  double? driver_lang;
  Position? _currentPosition;

  double? user_lat;
  double? user_lang;

  Completer<GoogleMapController> _controller = Completer();

  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Map<MarkerId, Marker> markers = {};

  late LocationData currentLocation;
  Location? location;
  double CAMERA_ZOOM = 14.4746;
  double CAMERA_TILT = 80;
  double CAMERA_BEARING = 30;

  @override
  void initState() {
    super.initState();

    location = new Location();
    WidgetsFlutterBinding.ensureInitialized();
    PreferenceUtils.init();
    _getCurrentLocation();

    //second = int.parse(PreferenceUtils.getString(Constants.driver_auto_refrese));
    print("Seconds:$second");
    if (Constants.currentlat != 0.0 && Constants.currentlong != 0.0 ) {
      setState(() {
        if(PreferenceUtils.getString(Constants.previos_order_user_lat) != ''){
          user_lat = double.parse(PreferenceUtils.getString(Constants.previos_order_user_lat));
          user_lang = double.parse(PreferenceUtils.getString(Constants.previos_order_user_lang));
        }else{
          user_lat = 0.0;
          user_lang = 0.0;
        }

        assert(user_lat is double);
        assert(user_lang is double);

        driver_lat = Constants.currentlat;
        driver_lang = Constants.currentlong;

        double distanceInMeters = Geolocator.distanceBetween(
            driver_lat!, driver_lang!, user_lat!, user_lang!);
        double distanceinkm = distanceInMeters / 1000;
        String str = distanceinkm.toString();
        var distance12 = str.split('.');
        user_distance = distance12[0];

        /// origin marker
        /// // make sure to initialize before map loading
        BitmapDescriptor customIcon;
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
                'images/driver_map_image_7.png')
            .then((d) {
          customIcon = d;
          addMarker(LatLng(driver_lat!, driver_lang!), "origin", customIcon);
        });

        /// destination marker
        BitmapDescriptor customIcon1;
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
                'images/food_map_image_4.png')
            .then((d) {
          customIcon1 = d;
          addMarker(LatLng(user_lat!, user_lang!), "destination", customIcon1);
        });

        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
                  _getCurrentLocation();
                }));

        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: second), (Timer t) {
                  _getCurrentLocation();
                  // adddrivermarker(_controller, 1, GeoCoordinates(driver_lat, driver_lang));
                  PostDriverLocation(driver_lat, driver_lang);
                }));
      });
    } else {
      checkforpermission();
    }
    if (mounted) {
      setState(() {
        id = PreferenceUtils.getString(Constants.previos_order_id);
        orderId = PreferenceUtils.getString(Constants.previos_order_orderid);
        vendorname =
            PreferenceUtils.getString(Constants.previos_order_vendor_name);
        vendorAddress =
            PreferenceUtils.getString(Constants.previos_order_vendor_address);
        distance = PreferenceUtils.getString(Constants.previos_order_distance);
        username = PreferenceUtils.getString(Constants.previos_order_user_name);
        useraddress =
            PreferenceUtils.getString(Constants.previos_order_user_address);
        if(PreferenceUtils.getString(Constants.previos_order_user_lat) != '') {
          user_lat = double.parse(PreferenceUtils.getString(Constants.previos_order_user_lat));
          user_lang = double.parse(PreferenceUtils.getString(Constants.previos_order_user_lang));
        }else{
          user_lat = 0.0 ;
          user_lang = 0.0;

        }
        assert(user_lat is double);
        assert(user_lang is double);

        print("vendorname1223:$vendorname");
      });
    }

    setState(() {
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {
                driver_address = value;
                print("driver_address:$driver_address");
              }));
    });
    location!.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      updatePinOnMap();
    });

  }

  updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due

    // updated position
    //var pinPosition = LatLng(driver_lat,driver_lang);
    // final marker = markers.values.toList().firstWhere((item) => item.markerId == MarkerId('driver'));

    final marker = markers.values.toList().firstWhere((item) => item.markerId == MarkerId('origin'));

    Marker _marker = Marker(
      markerId: marker.markerId,
      position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      icon: marker.icon,
    );

    setState(() {
      markers[MarkerId('origin')] = _marker;
      //the marker is identified by the markerId and not with the index of the list
      // markers.update(markers[0].markerId, (_) => _marker) ;
    });

    /*sourcePinInfo.location = pinPosition;
      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));*/

  }

  void checkforpermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      print("denied");
      Constants.createSnackBar(Languages.of(context)!.allowlocationlable,
          context, Color(Constants.redtext));
    } else if (permission == LocationPermission.whileInUse) {
      print("whileInUse56362");
      _getCurrentLocation();
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {
                driver_address = value;
              }));
      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                print("origin123:$value");
                driver_lat = value!.latitude;
                driver_lang = value.longitude;
              }));
      setState(() {
        _getCurrentLocation();
        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: second), (Timer t) {
                  // adddrivermarker(_controller, 1, GeoCoordinates(driver_lat, driver_lang));
                  PostDriverLocation(driver_lat, driver_lang);
                }));
      });
    } else if (permission == LocationPermission.always) {
      print("always");
      _getCurrentLocation();
      Constants.cuttentlocation()
          .whenComplete(() => Constants.cuttentlocation().then((value) {
                driver_address = value;
              }));
      Constants.currentlatlong()
          .whenComplete(() => Constants.currentlatlong().then((value) {
                driver_lat = value!.latitude;
                driver_lang = value.longitude;
              }));
      setState(() {
        _getCurrentLocation();
        Constants.CheckNetwork().whenComplete(
            () => timer = Timer.periodic(Duration(seconds: second), (Timer t) {
                  //adddrivermarker(_controller, 1, GeoCoordinates(driver_lat, driver_lang));
                  PostDriverLocation(driver_lat, driver_lang);
                }));
      });
    }
  }

  void PostDriverLocation(double? currentlat, double? currentlang) {
    print("UpdateLat:$currentlat");
    print("UpdateLang:$currentlang");

    // adddrivermarker(_controller, 1, GeoCoordinates(currentlat, currentlang));

    RestClient(Api_Header().Dio_Data())
        .driveupdatelatlong(currentlat.toString(), currentlang.toString())
        .then((response) {
      final body = json.decode(response!);
      bool? sucess = body['success'];
      if (sucess = true) {
        print("sucess lat long update");
        //removelatlong(GeoCoordinates(currentlat, currentlang));
      } else if (sucess == false) {
        print("false lat long update");
      }
    }).catchError((Object obj) {
      final snackBar = SnackBar(
        content: Text(Languages.of(context)!.servererrorlable),
        backgroundColor: Color(Constants.redtext),
      );
      _scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {});
      print("error:$obj");
      print(obj.runtimeType);
    });
  }

/*  void removelatlong(GeoCoordinates geoCoordinates,) async {
    ByteData fileData = await rootBundle.load('images/driver_map_image_7.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
       MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = 1;
    _controller.mapScene.removeMapMarker(mapMarker);
    print("remove12");
  }*/

  void CallApiForDeliverorder(BuildContext context) {
    setState(() {
       showSpinner = true;
    });

    if (mounted) {
      RestClient(Api_Header().Dio_Data())
          .orderstatuschange1(id, "COMPLETE")
          .then((response) {
        print("order_complete_response:$response");

        final body = json.decode(response!);
        bool? sucess = body['success'];
        // bool sucess =response.success;
        if (sucess = true) {
          setState(() {
            showSpinner = false;
          });
          setState(() {
            PreferenceUtils.setString(
                Constants.previos_order_status, "COMPLETE");
          });

          setState(() {
            timer?.cancel();
          });

          Navigator.of(this.context)
              .push(MaterialPageRoute(builder: (context) => OrderDeliverd()));
        } else if (sucess == false) {
          var msg = Languages.of(context)!.tryagainlable;
          Constants.createSnackBar(msg, this.context, Color(Constants.redtext));
        }
      }).catchError((Object obj) {
        final snackBar = SnackBar(
          content: Text(Languages.of(context)!.servererrorlable),
          backgroundColor: Color(Constants.redtext),
        );
        _scaffoldKey.currentState!.showSnackBar(snackBar);
        setState(() {
          showSpinner = false;
        });
        print("error:$obj");
        print(obj.runtimeType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenHeight = MediaQuery.of(context).size.height;

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
              body: ModalProgressHUD(
                inAsyncCall: showSpinner,
                opacity: 1.0,
                color: Colors.transparent.withOpacity(0.2),
                progressIndicator:
                    SpinKitFadingCircle(color: Color(Constants.greentext)),
                child: LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return new Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 00),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: screenHeight * 0.7,
                                  child: Stack(
                                    children: [
                                      Container(
                                        child: GoogleMap(
                                            mapType: MapType.normal,
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: LatLng(
                                                  driver_lat!, driver_lang!),
                                              zoom: 14.4746,
                                            ),
                                            myLocationEnabled: true,
                                            tiltGesturesEnabled: true,
                                            compassEnabled: true,
                                            scrollGesturesEnabled: true,
                                            zoomGesturesEnabled: true,
                                            markers:
                                                Set<Marker>.of(markers.values),
                                            polylines: Set<Polyline>.of(
                                                polylines.values),
                                            onMapCreated: onMapCreated),
                                      ),
                                      Container(
                                        alignment: Alignment.topRight,
                                        margin:
                                            EdgeInsets.only(right: 20, top: 10),
                                        child: RaisedButton(
                                          elevation: 5.0,
                                          textColor: Colors.white,
                                          color: Color(Constants.color_theme),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10.0, 10.0, 10.0, 10.0),
                                            child: Text(
                                              'Go To Map',
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (user_lat != null &&
                                                user_lang != null) {
                                              openMap(user_lat, user_lang);
                                            }
                                          },
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(15.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    vi_footer = true;
                                    vi_combtn = false;
                                    vi_address = true;
                                  });
                                },
                                child: Visibility(
                                  visible: vi_combtn,
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    margin: EdgeInsets.only(
                                        left: 0, bottom: 5, right: 10),
                                    child:
                                        SvgPicture.asset("images/map_zoom.svg"),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Visibility(
                                  visible: vi_address,
                                  child: Container(
                                    height: ScreenUtil().setHeight(220),
                                    margin: EdgeInsets.only(
                                        left: 20, top: 10, bottom: 60),
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: Text(Languages.of(context)!.oidlable + "   " + orderId,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  vi_footer = false;
                                                  vi_combtn = true;
                                                  vi_address = false;
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 10,
                                                ),
                                                child: SvgPicture.asset(
                                                    "images/map_zoom.svg"),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: ScreenUtil().setHeight(150),
                                          margin: EdgeInsets.only(top: 20),
                                          child: ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: 2,
                                              itemBuilder: (con, index) {
                                                double linetop = 0;
                                                double dottop = 0;
                                                double statustop = 0;
                                                Color? color;
                                                Color dotcolor;

                                                if (index == 0) {
                                                  dotcolor = Color(
                                                      Constants.greentext);
                                                }

                                                if (index == 1) {
                                                  linetop = -30.0;
                                                  dottop = -42.0;
                                                  statustop = -35.0;
                                                  color = Color(
                                                      Constants.greentext);
                                                  dotcolor = Color(
                                                      Constants.greentext);
                                                }

                                                return index != 0
                                                    ? Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                            Row(children: [
                                                              Column(
                                                                children: List
                                                                    .generate(
                                                                  4,
                                                                  (ii) =>
                                                                      Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 9,
                                                                        right:
                                                                            10,
                                                                        top: 0,
                                                                        bottom:
                                                                            0),
                                                                    child:
                                                                        Container(
                                                                      transform: Matrix4.translationValues(
                                                                          1.0,
                                                                          linetop,
                                                                          0.0),
                                                                      height:
                                                                          20,
                                                                      width: 2,
                                                                      color:
                                                                          color,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      Container(
                                                                color: Colors
                                                                    .transparent,
                                                                height: 0.5,
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: 10,
                                                                  right: 20,
                                                                ),
                                                              ))
                                                            ]),
                                                            Row(children: [
                                                              Container(
                                                                transform: Matrix4
                                                                    .translationValues(
                                                                        3.0,
                                                                        dottop,
                                                                        0.0),
                                                                child: SvgPicture
                                                                    .asset(
                                                                        "images/kitchen.svg"),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  color: Colors
                                                                      .transparent,
                                                                  transform: Matrix4
                                                                      .translationValues(
                                                                          20.0,
                                                                          statustop,
                                                                          0.0),
                                                                  child:
                                                                      ListView(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                              username,
                                                                              style: TextStyle(color: Color(Constants.whitetext), fontSize: 16, fontFamily: Constants.app_font_bold)),
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(right: 35),
                                                                            child:
                                                                                RichText(
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textScaleFactor: 1,
                                                                              text: TextSpan(
                                                                                children: [
                                                                                  WidgetSpan(
                                                                                    child: Container(
                                                                                      margin: EdgeInsets.only(left: 5, top: 0, bottom: 0, right: 5),
                                                                                      child: SvgPicture.asset(
                                                                                        "images/location.svg",
                                                                                        width: 13,
                                                                                        height: 13,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  WidgetSpan(
                                                                                    child: Container(
                                                                                      margin: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 5),
                                                                                      child: Text(
                                                                                        user_distance + " " + Languages.of(context)!.kmfarawaylable,
                                                                                        maxLines: 4,
                                                                                        style: TextStyle(
                                                                                          color: Color(Constants.whitetext),
                                                                                          fontSize: 12,
                                                                                          fontFamily: Constants.app_font,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                2),
                                                                        child: Text(
                                                                            useraddress,
                                                                            maxLines:
                                                                                3,
                                                                            overflow: TextOverflow
                                                                                .visible,
                                                                            style: TextStyle(
                                                                                color: Color(Constants.whitetext),
                                                                                fontSize: 12,
                                                                                fontFamily: Constants.app_font)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ])
                                                          ])
                                                    : Row(children: [
                                                        Container(
                                                          transform: Matrix4
                                                              .translationValues(
                                                                  2.0,
                                                                  -12,
                                                                  0.0),
                                                          child: SvgPicture.asset(
                                                              "images/map.svg",
                                                              width: 20,
                                                              height: 20),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            height: 55,
                                                            color: Colors
                                                                .transparent,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 20,
                                                                    top: 0,
                                                                    right: 10),
                                                            child: ListView(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              children: [
                                                                Text(vendorname,
                                                                    style: TextStyle(
                                                                        color: Color(Constants
                                                                            .whitetext),
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            Constants.app_font_bold)),
                                                                Text(
                                                                    vendorAddress,
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .visible,
                                                                    style: TextStyle(
                                                                        color: Color(Constants
                                                                            .whitetext),
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            Constants.app_font)),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ]);
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                            visible: vi_footer,
                            child: new Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    child: InkWell(
                                  onTap: () {
                                    Constants.CheckNetwork().whenComplete(
                                        () => CallApiForDeliverorder(this.context));
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          left: 0, right: 0, bottom: 0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        color: Color(Constants.greentext),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 0.0),
                                            //(x,y)
                                            blurRadius: 0.0,
                                          ),
                                        ],
                                      ),
                                      height: screenHeight * 0.08,
                                      child: Center(
                                        child: Container(
                                          color: Color(Constants.greentext),
                                          child: Text(
                                            Languages.of(context)!
                                                .completeorderlable,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: Constants.app_font),
                                          ),
                                        ),
                                      )),
                                )),
                              ),
                            )),
                      ],
                    );
                  },
                ),
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }

  addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  void onMapCreated(GoogleMapController googleMapController) async {
    check().then((intenet) async {
      if (intenet) {
        setState(() {
          showSpinner = true;
        });

        String platform = 'android';
        if (Platform.isAndroid) {
          platform = Constants.androidKey;
        } else if (Platform.isIOS) {
          platform =Constants.iosKey;
        }
        try{
        _controller.complete(googleMapController);

        PolylinePoints polylinePoints = PolylinePoints();
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            platform ,
            PointLatLng(driver_lat!, driver_lang!),
            PointLatLng(user_lat!, user_lang!));
        print(result.points);
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }

        PolylineId id = PolylineId("poly");
        Polyline polyline = Polyline(
            polylineId: id, color: Colors.green, points: polylineCoordinates);
        polylines[id] = polyline;

        }catch (e){
          print(e.toString());
        }
        /* googleMapController.mapId.loadSceneForMapScheme(MapScheme.greyNight,
            (error) {
          if (error != null) {
            print('Error:' + error.toString());
            return;
          }
        });*/

        /* drawdriverDot(hereMapController, 0, GeoCoordinates(driver_lat, driver_lang));

        drawRoute(GeoCoordinates(driver_lat, driver_lang),
         GeoCoordinates(user_lat, user_lang), hereMapController);
        drawvendorDot(hereMapController, 2, GeoCoordinates(user_lat, user_lang));
        double distanceToEarthInMeters = 5000;
        hereMapController.camera.lookAtPointWithDistance(
            GeoCoordinates(driver_lat, driver_lang), distanceToEarthInMeters);*/
        setState(() {
          showSpinner = false;
        });
      } else {
        showDialog(
          builder: (context) => AlertDialog(
            title: Text(Languages.of(context)!.checkinternetlable),
            content: Text(Languages.of(context)!.internetconnectionlable),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PickUpOrder(),
                      ));
                },
                child: Text(Languages.of(context)!.oklable),
              )
            ],
          ),
          context: context,
        );
      }
    });
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  /*Future<void> drawdriverDot(
    HereMapController hereMapController,
    int drawOrder,
    GeoCoordinates geoCoordinates,
  ) async {
    ByteData fileData = await rootBundle.load('images/driver_map_image_7.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }*/

  /* Future<void> adddrivermarker(
    HereMapController hereMapController,
    int drawOrder,
    GeoCoordinates geoCoordinates,
  ) async {
    ByteData fileData = await rootBundle.load('images/driver_map_image_7.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }*/

  /*Future<void> drawvendorDot(
    HereMapController hereMapController,
    int drawOrder,
    GeoCoordinates geoCoordinates,
  ) async {
    ByteData fileData = await rootBundle.load('images/food_map_image_4.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }*/

  /* Future<void> drawPin(
    HereMapController hereMapController,
    int drawOrder,
    GeoCoordinates geoCoordinates,
  ) async {
    //print("dsds");
    ByteData fileData = await rootBundle.load('images/driver_image.png');
    Uint8List pixelData = fileData.buffer.asUint8List();
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    Anchor2D anchor2d = Anchor2D.withHorizontalAndVertical(0.5, 1);
    MapMarker mapMarker =
        MapMarker.withAnchor(geoCoordinates, mapImage, anchor2d);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }*/

  /*Future<void> drawRoute(GeoCoordinates start, GeoCoordinates end,
      HereMapController hereMapController) async {
    //create a routing engine
    RoutingEngine routingEngine = RoutingEngine();

    //make a way point
    Waypoint startWayPoint = Waypoint.withDefaults(start);
    Waypoint endWayPoint = Waypoint.withDefaults(end);
    List<Waypoint> wayPoints = [startWayPoint, endWayPoint];

    //calculate the route
    routingEngine.calculateCarRoute(wayPoints, CarOptions.withDefaults(),
        (routingError, routes) {
      if (routingError == null) {
        var route = routes.first;

        //create a polyline
        GeoPolyline routeGeoPolyline = GeoPolyline(route.polyline);

        //create a visual representation for the polyline
        double depth = 10;
        _mapPolyline = MapPolyline(routeGeoPolyline, depth, Colors.green);

        //install de controller to draw on the map
        hereMapController.mapScene.addMapPolyline(_mapPolyline);
      }
    });
  }*/

  _getCurrentLocation() {
    Geolocator.getCurrentPosition()
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        driver_lat = position.latitude;
        driver_lang = position.longitude;

        print("driver_lat852:${driver_lat}");
        print("driver_lang852:${driver_lang}");
      });

      //_getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  static Future<void> openMap(double? latitude, double? longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    String urlAppleMaps = "https://maps.apple.com/?query=$latitude,$longitude";
    if (Platform.isAndroid) {
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    } else {
      if (await canLaunch(urlAppleMaps)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }
  }
}
