import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersioningTimeChecker{

  static SharedPreferences _sharedPreferences;
  static const String _PREVIOUS_TIME = '_versioning_previous_time';
  static const String _DONE = '_versioning_done';
  static const String _NUM_STEP = '_versioning_steps';

  static Future<bool> checkIfTime({int firstTime, int secondTime}) async {

    _sharedPreferences = await SharedPreferences.getInstance();

    bool done = _sharedPreferences.getBool(_DONE) ?? false;
    if(done) {
      debugPrint('Versioning: Already done!');
      return false; // already reviewed
    }

    int lastTime = _sharedPreferences.getInt(_PREVIOUS_TIME);
    if(lastTime==null) { // This is the very first time. Ask now!
      debugPrint('Versioning: This is the first time... ask to update');
      setLastTime();
      return true;
    }

    DateTime lastDateTime = DateTime.fromMillisecondsSinceEpoch(lastTime);
    var diff = DateTime.now().difference(lastDateTime);

    int step = _sharedPreferences.getInt(_NUM_STEP) ?? 0;
    bool isTime = false;

    debugPrint('Versioning: Last time was... ${lastDateTime.toString()}, step: $step');
    switch(step){
      case 0:
      case 1: // skipping 1/2 steps because we need to launch it immediatly at first time
        break;
      case 2: 
        isTime = diff.inDays>=firstTime;
        break;
      case 3:
        isTime = diff.inDays>=secondTime;
        break;
      default: 
        print('Versioning: do not delay anymore');
    }

    // * change here to debug
    if(isTime) {
      debugPrint('Versioning: It is time to update...');
      return true;
    }else{
      debugPrint('Versioning: Not time... too early ${diff.inHours}');
    }
      
    return false;
  }

  static void setLastTime() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    int step = _sharedPreferences.getInt(_NUM_STEP) ?? 0;

    _sharedPreferences.setInt(_PREVIOUS_TIME, DateTime.now().millisecondsSinceEpoch);
    _sharedPreferences.setInt(_NUM_STEP, ++step);
  }

  static void setAsDone() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setBool(_DONE, true);
  }

  static void reset() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.remove(_PREVIOUS_TIME);
    _sharedPreferences.remove(_DONE);
    _sharedPreferences.remove(_NUM_STEP);
  }
  

}