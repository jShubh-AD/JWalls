import '../domain/favourite_repository.dart';
import 'favourite_model.dart';
import 'local_datasource.dart';

class FavouriteRepositoryImpl implements FavouriteRepository {
  final LocalDatabase _localDatabase = LocalDatabase.instance;

  @override
  Future<void> addFavourite(FavouriteModel fav) async {
    await _localDatabase.addFavourite(fav);
  }

  @override
  List<FavouriteModel> getFavourites() {
    return _localDatabase.getFavourites();
  }

  @override
  FavouriteModel? getFavourite(String id) {
    return _localDatabase.getFavourite(id);
  }

  @override
  bool isFavourite(String id) {
    return _localDatabase.isFavourite(id);
  }

  @override
  Future<void> removeFavourite(String id) async {
    await _localDatabase.removeFavourite(id);
  }

  @override
  Future<bool> toggleFavourite(FavouriteModel fav) async {
    return await _localDatabase.toggleFavourite(fav);
  }

  @override
  String getLikedFolderPath() {
    return _localDatabase.likedFolder.path;
  }
}
