import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'favourite_model.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  static const String _favBox = 'favourites';
  static const String _searchHistoryBox = 'search_history';
  late Directory _likedFolder;

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_favBox);
    await Hive.openBox(_searchHistoryBox);

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

  // SEARCH HISTORY METHODS
  List<String> getSearchHistory() {
    final box = Hive.box(_searchHistoryBox);
    return box.values.cast<String>().toList().reversed.toList();
  }

  Future<void> addSearchHistory(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final box = Hive.box(_searchHistoryBox);
    
    // If query exists, delete it first to move it to the end (newest)
    if (box.containsKey(cleanQuery)) {
      await box.delete(cleanQuery);
    }
    
    await box.put(cleanQuery, cleanQuery);

    // Keep only the 20 most recent searches
    final keys = box.keys.toList();
    if (keys.length > 20) {
      await box.delete(keys.first);
    }
  }

  Future<void> removeSearchHistory(String query) async {
    await Hive.box(_searchHistoryBox).delete(query.trim());
  }

  Future<void> clearSearchHistory() async {
    await Hive.box(_searchHistoryBox).clear();
  }
}