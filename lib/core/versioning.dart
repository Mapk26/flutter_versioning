library versioning;

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versioning/core/api_provider.dart';
import 'package:versioning/core/base_options.dart';
import 'package:versioning/screens/maintenance_screen.dart';
import 'package:versioning/core/time_checker.dart';
import 'package:versioning/models/version_model.dart';
import 'package:package_info/package_info.dart';

enum VersionStatus {
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
  final String iosAppId;
  final String androidAppId;
  final VersioningOptions options;
  final int firstRember;
  final int secondRember;


  Versioning({
    @required this.options,
    @required this.child,
    this.loader,
    this.key,
    @required this.projectName,
    @required this.projectId,
    this.iosAppId,
    this.androidAppId,
    this.firstRember = 1,
    this.secondRember = 7,
  }) : super(key: key);

  @override
  _VersioningState createState() => _VersioningState();
}

class _VersioningState extends State<Versioning> with WidgetsBindingObserver {

  Future<VersionStatus> _futureStatus;
  String appName = '';
  VersionModel version;
  PackageInfo packageInfo;
  String currentVersion, buildNumber = '';
  static const String _BLOCK_ENABLED = '_versioning_block_enabled';

  Future<VersionStatus> _checkVersion(bool force) async {

    if(version!=null && !force) return VersionStatus.ignore;

    if(packageInfo==null)
      packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.tryParse(packageInfo.buildNumber);
    appName = packageInfo.appName;

    if(version==null || force){
      print('Versioning: calling Firebase...');
      version = await Api.getVersion(
        projectName: widget.projectName,
        projectId: widget.projectId,
      );
    }
      
    if(version==null){
      // Network error
      return VersionStatus.unknown;
    }else{
      // Save values in sharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(_BLOCK_ENABLED, version.blockEnabled);
      print('Versioning--> isblockEnabled: ${version.blockEnabled}',);
    }

    if(version.maintenanceMode){
      return VersionStatus.maintenance;
    }

    if( version.lastBreakingChange>buildNumber ) {
      print('Versioning--> breaking change');
      return VersionStatus.mustUpgrade;
    }else if( version.buildNumber>buildNumber ) {
      print('Versioning--> should upgrade');
      return VersionStatus.shouldUpgrade;
    }
    
    return VersionStatus.upToDate;

  }

  void _showShouldUpgrade() async {

    VersionStatus status = await _futureStatus;

    if(status!=null && status!=VersionStatus.ignore && status==VersionStatus.shouldUpgrade){

      if(!await VersioningTimeChecker.checkIfTime(firstTime: widget.firstRember, secondTime: widget.secondRember,))
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
                LaunchReview.launch(
                  writeReview: false,
                  iOSAppId: widget.iosAppId, 
                  androidAppId: widget.androidAppId,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

  }

  
  void initPlatform() async {
    packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      currentVersion = 'Version ${packageInfo.version}';
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
        builder: (context, AsyncSnapshot<VersionStatus> snapshot){

          if(snapshot.hasData){

            switch(snapshot.data){
              case VersionStatus.maintenance:
                return Maintenance(
                  appName: appName,
                  options: widget.options,
                  maintenanceText: version.maintenanceText ?? '',
                );
              case VersionStatus.mustUpgrade:
                return Maintenance(
                  appName: appName,
                  forceUpgrade: true,
                  options: widget.options,
                  updateText: version.updateText ?? '',
                );
              case VersionStatus.unknown: // ? in case of a connection error do now manage here
              case VersionStatus.shouldUpgrade:
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

                  const Spacer(flex: 2,),

                  if(widget.options.logo!=null)
                    widget.options.logo,

                  widget.loader==null ? CircularProgressIndicator() : widget.loader,

                  const Spacer(flex: 2,),

                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text('${currentVersion??''} ${buildNumber??''}',
                      style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold,),
                    ),
                  ),

                  const Spacer(flex: 1,),

                ],
              ),
            ),
          );
        }

    );
  }
}