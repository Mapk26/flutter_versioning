import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:versioning/core/base_options.dart';

class Maintenance extends StatelessWidget {

  final bool forceUpgrade, statusUnknown;
  final String appName;
  final VersioningOptions options;
  final String updateText, maintenanceText;

  Maintenance({
    this.appName,
    this.forceUpgrade=false,
    this.options,
    this.maintenanceText='',
    this.updateText='',
    this.statusUnknown=false,
  });

  @override
  Widget build(BuildContext context) {

    String message;
    Text textBox;
    Icon icon, defaultIcon;

    if(statusUnknown){

      textBox = Text('Something has went wrong, please check your connection.');
      icon = Icon(
        Icons.signal_cellular_connected_no_internet_4_bar,
        size: 90.0,
      );

    }else{
      message = forceUpgrade
          ? 'A new version of ${appName.isNotEmpty ? appName : 'this app'} is available.\nPlease update now.'
          : 'We\'re currently offline...\nwe\'ll be back ASAP!';

      textBox = Text(
        forceUpgrade && updateText.isNotEmpty
            ? updateText
            : !forceUpgrade && maintenanceText.isNotEmpty
              ? maintenanceText
              : message,
        textAlign: TextAlign.center,
        style: options.textStyle!=null
            ? options.textStyle
            : TextStyle(fontSize: 16.0, color: Colors.white,),
      );

      defaultIcon = Icon(
        forceUpgrade
            ? Icons.category
            : Icons.access_time,
        size: 90.0,
        color: Colors.white,
      );

      icon = defaultIcon;
      if(forceUpgrade && options.iconUpdate!=null){
        icon = options.iconUpdate;
      }else if(!forceUpgrade && options.iconMaintenance!=null){
        icon = options.iconMaintenance;
      }
    }


    return Scaffold(

      body: Center(
        child: Container(
          width: double.infinity,
          color: options.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              icon,

              SizedBox(height: 10.0,),

              SizedBox(
                width: MediaQuery.of(context).size.width-80.0,
                child: textBox,
              ),

              forceUpgrade ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FlatButton(
                  color: options.buttonColor!=null ? options.buttonColor : Colors.white.withOpacity(0.8),
                  child: Text(
                    options.buttonText!=null ? options.buttonText : 'Update',
                    semanticsLabel: options.buttonText!=null ? options.buttonText : 'Update',
                    style: options.buttonTextStyle!=null ? options.buttonTextStyle : TextStyle(color: Colors.blueAccent, fontSize: 16.0,),
                  ),
                  onPressed: LaunchReview.launch,
                ),
              ) : SizedBox(),

            ],
          ),
        ),
      ),

    );
  }
}
