import 'package:flutter/material.dart';

class VersioningOptions{

  Color backgroundColor, buttonColor;
  TextStyle textStyle, buttonTextStyle;
  Icon iconMaintenance, iconUpdate;
  String buttonText;
  String alertTitle, alertText, alertButtonUpgrade, alertButtonLater;


  VersioningOptions({
    this.backgroundColor = Colors.blueAccent,
    this.buttonColor,
    this.textStyle,
    this.iconMaintenance,
    this.iconUpdate,
    this.buttonText,
    this.buttonTextStyle,
    this.alertTitle = 'New version',
    this.alertText = 'A new version is available, download it now?',
    this.alertButtonUpgrade = 'Upgrade',
    this.alertButtonLater = 'Later',
  });
}