import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:walpy/core/http_const/api_const.dart';
import 'package:get/get.dart';

import '../Models/UserModel.dart';

class User_Datasource {
  /// Fetches a user profile from Unsplash and maps it to `UserModel`.
  Future<UserModel?> fetchUser(String id) async {

    final uri = Uri.parse('${ApiConst.fetchImageId.baseUrl()}/$id/${ApiConst.key}');

    try{
      final res = await http.get(uri);
      if(res.statusCode == 200){
        final data= await compute(heavyTask, res.body);
        return data;
      }else {
        Get.snackbar(
          'Error',
          'Server error: ${res.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

    }on SocketException{
      Get.snackbar(
        'No Internet',
        'Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch(e) {
      Get.snackbar(
        'Error',
        'Something went wrong!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
    return null;
  }
  static Future<UserModel> heavyTask(String responseBody) async{
    Map<String,dynamic> data = jsonDecode(responseBody);
      return UserModel.fromJson(data["user"]);
  }
}
