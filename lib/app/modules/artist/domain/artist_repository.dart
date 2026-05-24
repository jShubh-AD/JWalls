import 'package:walpy/app/core/network/result.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

abstract interface class ArtistRepository {
  Future<Result<List<Wallpaper>, Failure>> getArtistPhotos({
    required String username,
    required Map<String, dynamic> params,
  });
}
