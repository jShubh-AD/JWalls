import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'fav-model.g.dart';

@HiveType(typeId: 0)
class FavModel extends HiveObject {
  @HiveField(0)
  final String id;           // wallpaper ID

  @HiveField(1)
  final Uint8List bytes;     // full‑res image bytes

  FavModel({required this.id, required this.bytes});
}
