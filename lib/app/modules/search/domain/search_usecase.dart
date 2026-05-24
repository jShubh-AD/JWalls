import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/search/domain/search_repo.dart';

class SearchUseCase {
  final SearchRepository repo;

  SearchUseCase(this.repo);

  Future<Result<List<Wallpaper>, Failure>> searchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    return await repo.searchWallpapers(params: params, url: url);
  }
}
