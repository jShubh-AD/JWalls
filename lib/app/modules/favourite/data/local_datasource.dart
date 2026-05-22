import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'favourite_model.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  static const String _favBox = 'favourites';
  late Directory _likedFolder;

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_favBox);

    final dir = await getApplicationDocumentsDirectory();
    _likedFolder = Directory('${dir.path}/liked');
    if (!await _likedFolder.exists()) await _likedFolder.create();
  }

  Directory get likedFolder => _likedFolder;

  // CREATE
  Future<void> addFavourite(FavouriteModel fav) async {
    await Hive.box(_favBox).put(fav.id, jsonEncode(fav.toJson()));
  }

  // READ ALL
  List<FavouriteModel> getFavourites() {
    return Hive.box(_favBox).values
        .map((e) => FavouriteModel.fromJson(jsonDecode(e)))
        .toList();
  }

  // READ ONE
  FavouriteModel? getFavourite(String id) {
    final raw = Hive.box(_favBox).get(id);
    if (raw == null) return null;
    return FavouriteModel.fromJson(jsonDecode(raw));
  }

  // CHECK
  bool isFavourite(String id) => Hive.box(_favBox).containsKey(id);

  // DELETE
  Future<void> removeFavourite(String id) async {
    await Hive.box(_favBox).delete(id);
  }

  // TOGGLE
  Future<bool> toggleFavourite(FavouriteModel fav) async {
    if (isFavourite(fav.id ?? "")) {
      await removeFavourite(fav.id ?? "");
      return false;
    } else {
      await addFavourite(fav);
      return true;
    }
  }
}