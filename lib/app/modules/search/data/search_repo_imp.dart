import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/modules/search/data/search_datasource.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/search/domain/search_repo.dart';

class SearchRepoImp implements SearchRepository {
  final SearchDatasource _datasource = SearchDatasource();

  @override
  Future<Result<List<Wallpaper>, Failure>> searchWallpapers({
    required Map<String, dynamic> params,
    required String url,
  }) async {
    try {
      final wallpapers = await _datasource.fetchSearchWallpapers(params: params, url: url);
      return Success(wallpapers);
    } on NoInternetException {
      return const FailureResult(NetworkFailure());
    } on TimeoutException {
      return const FailureResult(TimeoutFailure());
    } on RateLimitException {
      return const FailureResult(RateLimitFailure());
    } on UnauthorizedException {
      return const FailureResult(AuthFailure());
    } on ServerException catch (e) {
      return FailureResult(ServerFailure(e.message));
    } catch (e) {
      return FailureResult(UnknownFailure(e.toString()));
    }
  }
}
