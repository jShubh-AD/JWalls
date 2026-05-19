import 'package:walpy/app/modules/home/data/home_repo_imp.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

class HomeUseCase {
  final HomeRepoImp repo = HomeRepoImp();

  Future<List<Wallpaper>> getWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    return await repo.getWallpapers(params: params, url: url);
  }
}
