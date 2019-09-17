import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:versioning/models/version_model.dart';

class Api{

  static Future<VersionModel> getVersion({@required String projectId, @required String projectName}) async {
    Response response;
    Dio dio = new Dio();

    String platform = Platform.isAndroid ? 'android' : 'ios';

    try{
      response = await dio.get("https://$projectId.firebaseio.com/$projectName/$platform.json");

      if(response.statusCode==200){
        print(response.data.toString());
        return VersionModel.fromMap(response.data);
      }
      else if(response.statusCode==401){
        throw("Please enable Firebase Database rules: read = true, write = false.");
      }

    }catch(e){

      throw('An error occurred during HTTP fetch data: $e');
    }

    return null;

  }
}