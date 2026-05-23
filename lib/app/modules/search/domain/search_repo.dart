import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

abstract interface class SearchRepository {
  Future<List<Wallpaper>> searchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  });
}
