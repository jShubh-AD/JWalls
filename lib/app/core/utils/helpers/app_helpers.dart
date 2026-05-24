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
      queryParams['q'] = 70.toString();
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

  static String getImageExtension(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'png';
      }
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return 'jpg';
      }
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        return 'webp';
      }
      if (bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38) {
        return 'gif';
      }
    }
    return 'jpg';
  }
}
