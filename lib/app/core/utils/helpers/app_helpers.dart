import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class AppHelpers {

  static Future<Uint8List> urlToBytes(String imageUrl) async{
    final file = await DefaultCacheManager().getSingleFile(imageUrl);
    return await file.readAsBytes();
  }

  static Future<Uint8List> boundaryToBytes(RenderRepaintBoundary boundary) async{
    final ui.Image image = await boundary.toImage(
    pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

}