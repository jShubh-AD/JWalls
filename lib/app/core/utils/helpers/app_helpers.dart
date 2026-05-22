import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class AppHelpers {
  static Future<Uint8List> urlToBytes(String imageUrl) async {
    final file = await DefaultCacheManager().getSingleFile(imageUrl);
    return await file.readAsBytes();
  }

  static Future<Uint8List> boundaryToBytes(
    RenderRepaintBoundary boundary,
  ) async {
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static String optimizeUnsplashUrl(String url) {
    try {
      final uri = Uri.parse(url);

      if (!uri.host.contains('unsplash.com')) {
        return url;
      }

      print("Original: ${uri.toString()}");

      final queryParams = Map<String, String>.from(uri.queryParameters);

      queryParams['w'] = 1080.toString();
      queryParams['q'] = 60.toString();
      queryParams['fm'] = 'webp';
      queryParams['fit'] = 'max';
      queryParams['auto'] = 'format';

      final newUri = uri.replace(queryParameters: queryParams).toString();
      print("Optimized: $newUri");
      return newUri;
    } catch (e) {
      return url;
    }
  }
}
