import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/modules/artist/data/artist_datasource.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/artist/domain/artist_repository.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistDatasource _datasource = ArtistDatasource();

  @override
  Future<Result<List<Wallpaper>, Failure>> getArtistPhotos({
    required String username,
    required Map<String, dynamic> params,
  }) async {
    try {
      final wallpapers = await _datasource.fetchArtistPhotos(
        username: username,
        params: params,
      );
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
