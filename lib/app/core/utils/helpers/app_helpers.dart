import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class AppHelpers {

  static Future<Uint8List> getImageBytes(String imageUrl) async{
    final file = await DefaultCacheManager().getSingleFile(imageUrl);
    return await file.readAsBytes();
  }

  // static

}