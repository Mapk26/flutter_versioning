// To parse this JSON data, do
//
//     final versionModel = versionModelFromJson(jsonString);

import 'dart:convert';


class VersionModel {
  int buildNumber;
  int lastBreakingChange;
  bool maintenanceMode;
  String platform, maintenanceText, updateText;

  VersionModel({
    this.buildNumber,
    this.lastBreakingChange,
    this.maintenanceMode,
    this.platform,
    this.maintenanceText,
    this.updateText,
  });

  factory VersionModel.fromJson(String str) => VersionModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VersionModel.fromMap(Map<String, dynamic> json) => VersionModel(
    buildNumber: json["buildNumber"],
    lastBreakingChange: json["lastBreakingChange"],
    maintenanceMode: json["maintenanceMode"] ?? false,
    platform: json["platform"],
    maintenanceText: json["maintenanceText"] ?? '',
    updateText: json["updateText"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "buildNumber": buildNumber,
    "lastBreakingChange": lastBreakingChange,
    "maintenanceMode": maintenanceMode,
    "platform": platform,
  };
}
