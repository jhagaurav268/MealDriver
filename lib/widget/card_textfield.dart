import 'package:flutter/material.dart';
import 'package:mealup_driver/util/constants.dart';

class CardTextFieldWidget extends StatelessWidget {
  CardTextFieldWidget(
      {required this.hintText,
      required this.textInputType,
      required this.textInputAction,
      required this.textEditingController,
      this.errorText,
      this.validator,
      required this.focus});

  final String? hintText, errorText;
  Function? validator, focus;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(Constants.light_black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: TextFormField(
          textInputAction: textInputAction,
          onFieldSubmitted: focus as void Function(String)?,
          validator: validator as String? Function(String?)?,
          keyboardType: textInputType,
          controller: textEditingController,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: Constants.app_font_bold),
          decoration: Constants.kTextFieldInputDecoration
              .copyWith(hintText: hintText, errorText: errorText),
        ),
      ),
    );
  }
}
