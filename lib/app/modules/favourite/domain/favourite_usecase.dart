import '../data/favourite_model.dart';
import '../data/favourite_repository_impl.dart';
import 'favourite_repository.dart';

class FavouriteUseCase {
  final FavouriteRepository repo = FavouriteRepositoryImpl();

  Future<void> addFavourite(FavouriteModel fav) async {
    await repo.addFavourite(fav);
  }

  List<FavouriteModel> getFavourites() {
    return repo.getFavourites();
  }

  FavouriteModel? getFavourite(String id) {
    return repo.getFavourite(id);
  }

  bool isFavourite(String id) {
    return repo.isFavourite(id);
  }

  Future<void> removeFavourite(String id) async {
    await repo.removeFavourite(id);
  }

  Future<bool> toggleFavourite(FavouriteModel fav) async {
    return await repo.toggleFavourite(fav);
  }

  String getLikedFolderPath() {
    return repo.getLikedFolderPath();
  }
}
