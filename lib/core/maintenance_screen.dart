import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

class Maintenance extends StatelessWidget {

  final bool forceUpgrade;
  final String appName;

  Maintenance({this.appName, this.forceUpgrade=false});

  @override
  Widget build(BuildContext context) {

    String message = forceUpgrade
        ? 'A new version of ${appName.isNotEmpty ? appName : 'this app'} is available.\nPlease update now.'
        : 'We\'re currently offline...\nwe\'ll be back ASAP!';

    return Scaffold(

      body: Center(
        child: Container(
          width: double.infinity,
          color: Colors.blueAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Icon(
                forceUpgrade ? Icons.category : Icons.access_time,
                size: 80.0,
                color: Colors.white,
              ),

              SizedBox(height: 10.0,),

              SizedBox(
                width: MediaQuery.of(context).size.width-80.0,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.white,),
                ),
              ),

              forceUpgrade ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FlatButton(
                  color: Colors.white.withOpacity(0.8),
                  child: const Text(
                    'Update',
                    semanticsLabel: 'Update',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 16.0,),
                  ),
                  onPressed: () {
                    LaunchReview.launch();
                  },
                ),
              ) : SizedBox(),

            ],
          ),
        ),
      ),

    );
  }
}
