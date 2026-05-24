import 'package:flutter/foundation.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/dio_client.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

class HomeDatasource {
  final DioClient _dio = DioClient.instance;

  Future<List<Wallpaper>> fetchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    try{
      final response = await _dio.performGet(url: url, params: params);
      return await compute(heavyParsing, response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException("Failed to parse wallpapers: $e");
    }
  }
}

Future<List<Wallpaper>> heavyParsing(dynamic responseBody) async {
return Wallpaper.fromJsonList(responseBody);
}