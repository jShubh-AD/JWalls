import 'package:flutter/foundation.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/dio_client.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

class SearchDatasource {
  final dio = DioClient.instance;

  Future<List<Wallpaper>> fetchSearchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    try {
      final response = await dio.performGet(url: url, params: params);
      final results = response.data['results'];
      return await compute(heavySearchParsing, results);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException("Failed to parse search results: $e");
    }
  }
}

Future<List<Wallpaper>> heavySearchParsing(dynamic responseBody) async {
  if (responseBody == null) return [];
  return Wallpaper.fromJsonList(responseBody);
}
