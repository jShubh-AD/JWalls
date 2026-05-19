import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

abstract class HomeRepository {
  Future<List<Wallpaper>> getWallpapers({
    required Map<String, dynamic> params,
    required String url,
  });
}
