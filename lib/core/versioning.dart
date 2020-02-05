library versioning;

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:versioning/core/api_provider.dart';
import 'package:versioning/core/base_options.dart';
import 'package:versioning/core/maintenance_screen.dart';
import 'package:versioning/core/time_checker.dart';
import 'package:versioning/models/version_model.dart';
import 'package:package_info/package_info.dart';

enum versionStatus {
  maintenance,
  shouldUpgrade,
  mustUpgrade,
  upToDate,
  unknown, // network error
  ignore // ignore the status and go ahead
}

class Versioning extends StatefulWidget {

  final Widget child;
  final Widget loader;
  final Key key;
  final String projectId;
  final String projectName;
  final VersioningOptions options;

  Versioning({
    @required this.options,
    @required this.child,
    this.loader,
    this.key,
    @required this.projectName,
    @required this.projectId,
  }) : super(key: key);

  @override
  _VersioningState createState() => _VersioningState();
}

class _VersioningState extends State<Versioning> with WidgetsBindingObserver {

  Future<versionStatus> _futureStatus;
  String appName = '';
  VersionModel version;

  Future<versionStatus> _checkVersion(bool force) async {

    if(version!=null && !force) return versionStatus.ignore;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    appName = packageInfo.appName;

    if(version==null || force){
      print('Versioning: calling Firebase...');
      version = await Api.getVersion(
        projectName: widget.projectName,
        projectId: widget.projectId,
      );
    }
      
    if(version==null){
      return versionStatus.unknown;
    }

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

    if(data!=null && data!=versionStatus.ignore && data==versionStatus.shouldUpgrade){

      if(!await VersioningTimeChecker.checkIfTime(firstTime: 1, secondTime: 7,))
        return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => new AlertDialog(
          title: Text(widget.options.alertTitle),
          content: Text(widget.options.alertText),
          actions: <Widget>[
            new FlatButton(
              child: new Text(widget.options.alertButtonLater),
              onPressed: () {
                VersioningTimeChecker.setLastTime();
                Navigator.of(context).pop();
              } 
            ),
            new FlatButton(
              child: new Text(widget.options.alertButtonUpgrade),
              onPressed: () {
                VersioningTimeChecker.reset();
                LaunchReview.launch();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

  }

  String currentVersion, buildNumber = '';

  void initPlatform() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      currentVersion = 'Versione ${packageInfo.version}';
      buildNumber = '(${packageInfo.buildNumber})';
    });
  }

  @override
  void initState() {
    super.initState();

    // We will be able to check again
    // when returning to the application
    WidgetsBinding.instance.addObserver(this);
    initPlatform();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      _futureStatus = _checkVersion(false);
    });

    _showShouldUpgrade();
  }

  /// When the application has a resumed status,
  /// check for the permission status again
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App State resumed');
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _futureStatus = _checkVersion(true);
      });
      _showShouldUpgrade();
    }
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

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
              case versionStatus.unknown:
                return Maintenance(
                  appName: appName,
                  statusUnknown: true,
                  options: widget.options,
                );
              case versionStatus.shouldUpgrade:
              default:
                return widget.child;

            }
          }

          return Scaffold(
            backgroundColor: widget.options.backgroundColor,
            body: Container(
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  Spacer(flex: 2,),

                  widget.options.logo!=null ? widget.options.logo : SizedBox(),

                  widget.loader==null ? CircularProgressIndicator() : widget.loader,

                  Spacer(flex: 2,),

                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text('${currentVersion??''} ${buildNumber??''}',
                      style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold,),
                    ),
                  ),

                  Spacer(flex: 1,),

                ],
              ),
            ),
          );
        }

    );
  }
}