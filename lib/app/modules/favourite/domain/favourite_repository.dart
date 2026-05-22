import '../data/favourite_model.dart';

abstract interface class FavouriteRepository {
  Future<void> addFavourite(FavouriteModel fav);
  List<FavouriteModel> getFavourites();
  FavouriteModel? getFavourite(String id);
  bool isFavourite(String id);
  Future<void> removeFavourite(String id);
  Future<bool> toggleFavourite(FavouriteModel fav);
  String getLikedFolderPath();
}
