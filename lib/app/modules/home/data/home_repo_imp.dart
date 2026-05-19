import 'package:walpy/app/modules/home/data/home_datasource.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/home/domain/home_repo.dart';

class HomeRepoImp extends HomeRepository {
  @override
  Future<List<Wallpaper>> getWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    return await HomeDatasource().fetchWallpapers(params: params, url: url);
  }
}
