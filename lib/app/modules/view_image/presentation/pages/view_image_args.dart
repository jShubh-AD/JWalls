import 'package:walpy/app/modules/favourite/data/favourite_model.dart';
import '../../../home/data/wallaper_response_modle.dart';

class ViewImageArgs {
  final Wallpaper? wallInfo;
  final FavouriteModel? favouriteWall;

  ViewImageArgs({
    this.wallInfo,
    this.favouriteWall,
  });
}