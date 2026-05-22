import 'package:flutter/foundation.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/dio_client.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

class HomeDatasource {
  final dio = DioClient.instance;

  Future<List<Wallpaper>> fetchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    try{
      final response = await dio.performGet(url: url, params: params);
      return compute(heavyParsing, response.data);
    }catch(e) {
      throw AppException(e.toString());
    }
  }
}

Future<List<Wallpaper>> heavyParsing(dynamic responseBody) async {
return Wallpaper.fromJsonList(responseBody);
}