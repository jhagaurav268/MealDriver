import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup_driver/apiservice/Api_Header.dart';
import 'package:mealup_driver/apiservice/Apiservice.dart';
import 'package:mealup_driver/localization/language/languages.dart';
import 'package:mealup_driver/screen/login_screen.dart';
import 'package:mealup_driver/util/app_toolbar.dart';
import 'package:mealup_driver/util/constants.dart';
import 'package:mealup_driver/util/preferenceutils.dart';
import 'package:mealup_driver/widget/app_lable_widget.dart';
import 'package:mealup_driver/widget/card_password_textfield.dart';
import 'package:mealup_driver/widget/hero_image_app_logo.dart';
import 'package:mealup_driver/widget/rounded_corner_app_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ForgotPasswordNextScreen extends StatefulWidget {
  int? driver_id;

  ForgotPasswordNextScreen(this.driver_id);

  @override
  _ForgotPasswordNextScreen createState() => _ForgotPasswordNextScreen();
}

class _ForgotPasswordNextScreen extends State<ForgotPasswordNextScreen> {
  final _new_text_Password = TextEditingController();
  final _confirm_text_Password = TextEditingController();
  FocusNode _focusNode = new FocusNode();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _passwordVisible = true;

  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();

    _focusNode.addListener(() {
      print("Has focus: ${_focusNode.hasFocus}");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenHeight = MediaQuery.of(context).size.height;
    dynamic screenwidth = MediaQuery.of(context).size.width;

    double defaultScreenWidth = screenwidth;
    double defaultScreenHeight = screenHeight;

   /* ScreenUtil.init(context,
        designSize: Size(defaultScreenWidth, defaultScreenHeight),
        allowFontScaling: true);*/

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/background_image.png'),
          fit: BoxFit.cover,
        )),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context)!.forgotpasswordlabel,
          ),
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            opacity: 1.0,
            color: Colors.transparent.withOpacity(0.2),
            progressIndicator:
                SpinKitFadingCircle(color: Color(Constants.greentext)),
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          HeroImage(),
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                            child: SvgPicture.asset(
                              'images/email.svg',
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20),
                                right: ScreenUtil().setWidth(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppLableWidget(
                                  title: Languages.of(context)!.newpasswordlable,
                                ),
                                CardPasswordTextFieldWidget(
                                    textEditingController: _new_text_Password,
                                    validator: Constants.kvalidatePassword,
                                    hintText: Languages.of(context)!
                                        .enternewpasswordlable,
                                    isPasswordVisible: _passwordVisible),
                                AppLableWidget(
                                  title: Languages.of(context)!.confirmpasslable,
                                ),
                                CardPasswordTextFieldWidget(
                                    textEditingController:
                                        _confirm_text_Password,
                                    validator: validateConfPassword,
                                    hintText: Languages.of(context)!
                                        .enterpasswordlabel,
                                    isPasswordVisible: _passwordVisible),
                                SizedBox(
                                  height: ScreenUtil().setHeight(20),
                                ),
                                RoundedCornerAppButton(
                                    btn_lable:
                                        Languages.of(context)!.submitlable,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        print("true");

                                        // Constants.CheckNetwork().whenComplete(() => pr.show());
                                        Constants.CheckNetwork().whenComplete(
                                            () => CallChangePasswordApi(
                                                _new_text_Password.text,
                                                _confirm_text_Password.text,
                                                context));
                                      } else {
                                        setState(() {
                                          // validation error
                                          _autoValidate = true;
                                        });
                                      }
                                    }),
                                SizedBox(
                                  height: ScreenUtil().setHeight(15),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                            child: Text(
                              Languages.of(context)!.checkemailotplable,
                              style: TextStyle(
                                color: Color(Constants.color_gray),
                                fontSize: ScreenUtil().setSp(10),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String? validateConfPassword(String? value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return Languages.of(context)!.passwordrequiredlable;
    } else if (value.length < 6) {
      return Languages.of(context)!.passwordsixcharlable;
    } else if (_new_text_Password.text != _confirm_text_Password.text)
      return Languages.of(context)!.passwordnotmatchlable;
    else if (!regex.hasMatch(value))
      return Languages.of(context)!.passwordrequiredlable;
    else
      return null;
  }

  CallChangePasswordApi(
      String newpassword, String confirmpassword, BuildContext context) {
    setState(() {
      showSpinner = true;
    });

    RestClient(Api_Header().Dio_Data())
        .driverforgotpassword(
            newpassword, confirmpassword, widget.driver_id.toString())
        .then((response) {
      if (mounted) {
        print(response.toString());
        final body = json.decode(response!);

        bool? sucess = body['success'];
        print(sucess);

        if (sucess == true) {
          setState(() {
            showSpinner = false;
          });

          var msg = body['data'];

          Constants.createSnackBar(msg, this.context, Color(Constants.greentext));

          Navigator.push(
            this.context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          setState(() {
            showSpinner = false;
          });

          var msg = body['data'];

          Constants.createSnackBar(msg, this.context, Color(Constants.redtext));
        }
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
      //AppConstant.toastMessage("Internal Server Error");
    });
  }
}
