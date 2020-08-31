// To parse this JSON data, do
//
//     final versionModel = versionModelFromJson(jsonString);

import 'dart:convert';


class VersionModel {
  int buildNumber;
  int lastBreakingChange;
  bool maintenanceMode, blockEnabled;
  String platform, maintenanceText, updateText;

  VersionModel({
    this.buildNumber,
    this.lastBreakingChange,
    this.maintenanceMode,
    this.blockEnabled,
    this.platform,
    this.maintenanceText,
    this.updateText,
  });

  factory VersionModel.fromJson(String str) => VersionModel.fromMap(json.decode(str));

  factory VersionModel.fromMap(Map<String, dynamic> json) => VersionModel(
    buildNumber: json["buildNumber"],
    lastBreakingChange: json["lastBreakingChange"],
    maintenanceMode: json["maintenanceMode"] ?? false,
    blockEnabled: json["blockEnabled"] ?? false,
    platform: json["platform"],
    maintenanceText: json["maintenanceText"] ?? '',
    updateText: json["updateText"] ?? '',
  );

}
