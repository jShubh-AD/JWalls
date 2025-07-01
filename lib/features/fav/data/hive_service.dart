/*import 'package:hive/hive.dart';
import 'package:walpy/features/fav/data/fav-model.dart';

class FavService {
  Box<FavModel> box = Hive.box<FavModel>('favorites');

  // get all items
  List<FavModel> all() {
    return box.values.toList();
  }

  bool contains(String wallId) {
    return box.values.any((fav) => fav.id == wallId);  // O(n)
  }

  void add (FavModel fav){
    box.add(fav);
  }

  void delete(FavModel fav){
    box.delete(fav);
  }
  Future<bool> toggle(FavModel fav) async {
    if(contains(fav.id)){
      box.delete(fav);
      print('remove ${fav.id}');
      return false;
    }else{
      box.add(fav);
      print('added ${fav.id}');
      return true;
    }
  }

}
*/

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:walpy/features/fav/data/fav-model.dart';


class FavService {
  final Box<FavModel> _box = Hive.box<FavModel>('favorites');

  /* ---------- helpers ---------- */

  ValueListenable<Box<FavModel>> get listenable => _box.listenable();

  int? _findKeyById(String wallId) {
    // return the Hive key (int) for this wallpaper id, or null
    for (final key in _box.keys) {
      final fav = _box.get(key);
      if (fav != null && fav.id == wallId) return key;
    }
    return null;
  }

  /* ---------- public API ---------- */

  bool contains(String wallId) {
    return _box.values.any((fav) => fav.id == wallId);
  }

  Future<void> add(FavModel fav) async => _box.add(fav);

  Future<void> remove(String wallId) async {
    final key = _findKeyById(wallId);
    if (key != null) await _box.delete(key);
    print("fav deleted: $wallId");
  }

  /// Flip state & return NEW value (true = now liked)
  Future<bool> toggle(FavModel fav) async {
    if (contains(fav.id)) {
      await remove(fav.id);
      print('Removed ${fav.id}');
      return false;
    } else {
      await add(fav);
      print('Added  ${fav.id}');
      return true;
    }
  }
}

