import 'package:flutter/material.dart';

class VersioningOptions{

  Color backgroundColor, buttonColor;
  TextStyle textStyle, buttonTextStyle;
  Icon iconMaintenance, iconUpdate;
  String buttonText;
  String alertTitle, alertText, alertButtonUpgrade, alertButtonLater;
  Widget logo;

  VersioningOptions({
    this.logo,
    this.backgroundColor = Colors.blueAccent,
    this.textStyle = const TextStyle(fontSize: 14),
    this.iconMaintenance = const Icon(Icons.access_alarms),
    this.iconUpdate = const Icon(Icons.system_update),
    this.buttonColor = Colors.white,
    this.buttonText = 'Update',
    this.buttonTextStyle = const TextStyle(fontSize: 14),
    this.alertTitle = 'New version',
    this.alertText = 'A new version is available, download it now?',
    this.alertButtonUpgrade = 'Upgrade',
    this.alertButtonLater = 'Later',
  });
}