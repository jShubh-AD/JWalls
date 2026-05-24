import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

abstract interface class SearchRepository {
  Future<Result<List<Wallpaper>, Failure>> searchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  });
}
