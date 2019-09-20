library versioning;

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:versioning/core/api_provider.dart';
import 'package:versioning/core/base_options.dart';
import 'package:versioning/core/maintenance_screen.dart';
import 'package:versioning/models/version_model.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum versionStatus {
  maintenance,
  shouldUpgrade,
  mustUpgrade,
  upToDate,
}

class Versioning extends StatefulWidget {

  final Widget child;
  final key;
  final String projectId;
  final String projectName;
  final VersioningOptions options;

  Versioning({
    @required this.options,
    @required this.child,
    this.key,
    @required this.projectName,
    @required this.projectId,
  }) : super(key: key);

  @override
  _VersioningState createState() => _VersioningState();
}

class _VersioningState extends State<Versioning>
    with WidgetsBindingObserver, AfterLayoutMixin<Versioning>{

  Future<versionStatus> _futureStatus;
  String appName = '';
  VersionModel version;

  Future<versionStatus> _checkVersion() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    appName = packageInfo.appName;

    version = await Api.getVersion(
      projectName: widget.projectName,
      projectId: widget.projectId,
    );

    if(version.maintenanceMode){
      return versionStatus.maintenance;
    }

    if( version.lastBreakingChange>buildNumber ) {
      print('breaking change');
      return versionStatus.mustUpgrade;
    }else if( version.buildNumber>buildNumber ) {
      print('should upgrade');
      return versionStatus.shouldUpgrade;
    }else
      return versionStatus.upToDate;

  }

  void _showShouldUpgrade() async {

    versionStatus data = await _futureStatus;

    if(data!=null && data==versionStatus.shouldUpgrade){
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: const Text('New version'),
          content: const Text('A new version is available on the store. '
              'Do you want to update it now?'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Update'),
              onPressed: () {
                LaunchReview.launch();
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text('Later'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }

  }

  @override
  void initState() {
    super.initState();

    // We will be able to check again
    // when returning to the application
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      _futureStatus = _checkVersion();
    });

    _showShouldUpgrade();
  }


  /// When the application has a resumed status,
  /// check for the permission status again
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _futureStatus = _checkVersion();
      });
      _showShouldUpgrade();
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: _futureStatus,
        builder: (context, AsyncSnapshot<versionStatus> snapshot){

          if(snapshot.hasData){

            switch(snapshot.data){
              case versionStatus.maintenance:
                return Maintenance(
                  appName: appName,
                  options: widget.options,
                  maintenanceText: version.maintenanceText ?? '',
                );
              case versionStatus.mustUpgrade:
                return Maintenance(
                  appName: appName,
                  forceUpgrade: true,
                  options: widget.options,
                  updateText: version.updateText ?? '',
                );
              case versionStatus.shouldUpgrade:
              default:
                return widget.child;

            }
          }

          return Scaffold(
            body: Center(
              child: SpinKitCubeGrid(
                color: Colors.blueAccent,
              ),
            ),
          );
        }

    );
  }




}