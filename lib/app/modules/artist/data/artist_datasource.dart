import 'package:flutter/foundation.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/dio_client.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

class ArtistDatasource {
  final _dio = DioClient.instance;

  Future<List<Wallpaper>> fetchArtistPhotos({
    required String username,
    required Map<String, dynamic> params,
  }) async {
    try {
      final response = await _dio.performGet(
        url: 'users/$username/photos',
        params: params,
      );
      return await compute(heavyParsing, response.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException("Failed to parse artist photos: $e");
    }
  }
}

Future<List<Wallpaper>> heavyParsing(dynamic responseBody) async {
  if (responseBody == null) return [];
  return Wallpaper.fromJsonList(responseBody);
}
