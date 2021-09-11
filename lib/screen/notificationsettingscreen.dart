import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup_driver/util/constants.dart';

class NotificationSetting extends StatefulWidget {
  @override
  _NotificationSetting createState() => _NotificationSetting();
}

class _NotificationSetting extends State<NotificationSetting> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isSwitched = false;

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
      });
      print('Switch Button is OFF');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
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
              appBar: AppBar(
                title: Text(
                  "Notification Sound",
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(Constants.whitetext),
                    fontFamily: Constants.app_font_bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                automaticallyImplyLeading: true,
              ),
              body: new Stack(
                children: <Widget>[
                  new SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      color: Colors.transparent,
                      child: Column(
                        // physics: NeverScrollableScrollPhysics(),
                        // mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text(
                                    "New Message Notification",
                                    style: TextStyle(
                                        color: Color(Constants.whitetext),
                                        fontSize: 14,
                                        fontFamily: Constants.app_font),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        trackColor:
                                            Color(Constants.color_black),
                                        activeColor: Color(Constants.greentext),
                                        value: isSwitched,
                                        onChanged: (newval) {
                                          setState(() {
                                            isSwitched = !isSwitched;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 20, bottom: 0, right: 20),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Color(Constants.dashline),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "Mute All Notifications",
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 14,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 0),
                                        child: Text(
                                          "Mute all the notifications from this application",
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 12,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        trackColor:
                                            Color(Constants.color_black),
                                        activeColor: Color(Constants.greentext),
                                        value: isSwitched,
                                        onChanged: (newval) {
                                          setState(() {
                                            isSwitched = !isSwitched;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 20, bottom: 0, right: 20),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Color(Constants.dashline),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "Vibrate Mode",
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 14,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin:
                                            EdgeInsets.only(top: 0, right: 5),
                                        child: Text(
                                          "You can't feel sound of notifications, It will goes completely on vibrate mode",
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 12,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        trackColor:
                                            Color(Constants.color_black),
                                        activeColor: Color(Constants.greentext),
                                        value: isSwitched,
                                        onChanged: (newval) {
                                          setState(() {
                                            isSwitched = !isSwitched;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 20, bottom: 0, right: 20),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Color(Constants.dashline),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "Call Notification",
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 14,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin:
                                            EdgeInsets.only(top: 0, right: 5),
                                        child: Text(
                                          "You can't receive call notification from this application",
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 12,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        trackColor:
                                            Color(Constants.color_black),
                                        activeColor: Color(Constants.greentext),
                                        value: isSwitched,
                                        onChanged: (newval) {
                                          setState(() {
                                            isSwitched = !isSwitched;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 20, bottom: 0, right: 20),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Color(Constants.dashline),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "Do Not Disturb Mode",
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 14,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin:
                                            EdgeInsets.only(top: 0, right: 5),
                                        child: Text(
                                          "When a DND is enabled, You don't receive any kind of notification",
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 12,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        trackColor:
                                            Color(Constants.color_black),
                                        activeColor: Color(Constants.greentext),
                                        value: isSwitched,
                                        onChanged: (newval) {
                                          setState(() {
                                            isSwitched = !isSwitched;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: 10, left: 20, bottom: 0, right: 20),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Color(Constants.dashline),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          "New Task Notification",
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 14,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin:
                                            EdgeInsets.only(top: 0, right: 5),
                                        child: Text(
                                          "When it is disabled you don't receive new task notification on notification panel",
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              color: Color(Constants.whitetext),
                                              fontSize: 12,
                                              fontFamily: Constants.app_font),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        trackColor:
                                            Color(Constants.color_black),
                                        activeColor: Color(Constants.greentext),
                                        value: isSwitched,
                                        onChanged: (newval) {
                                          setState(() {
                                            isSwitched = !isSwitched;
                                          });
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async{
    return true;
  }
}
