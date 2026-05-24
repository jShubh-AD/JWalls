import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/artist/domain/artist_repository.dart';

class ArtistUseCase {
  final ArtistRepository repo;

  ArtistUseCase(this.repo);

  Future<Result<List<Wallpaper>, Failure>> getArtistPhotos({
    required String username,
    required Map<String, dynamic> params,
  }) async {
    return await repo.getArtistPhotos(username: username, params: params);
  }
}
