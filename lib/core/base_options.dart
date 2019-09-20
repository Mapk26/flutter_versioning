import 'package:flutter/material.dart';

class VersioningOptions{

  Color backgroundColor, buttonColor;
  TextStyle textStyle, buttonTextStyle;
  Icon iconMaintenance, iconUpdate;
  String buttonText;


  VersioningOptions({
    this.backgroundColor = Colors.blueAccent,
    this.buttonColor,
    this.textStyle,
    this.iconMaintenance,
    this.iconUpdate,
    this.buttonText,
    this.buttonTextStyle,
  });
}