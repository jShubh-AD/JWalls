import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class SetWallpaper extends GetxController{
  Future<void> setWall({required String imageUrl}) async{
    int location = WallpaperManagerFlutter.bothScreens;
    var fileInfo =  await DefaultCacheManager().getFileFromCache(imageUrl);

    if (fileInfo != null) {
      print("✅ wall was found in cache: ${fileInfo.file.path}");
    } else {
      print("❌ wall not in cache, will be downloaded.");
    }

    File file = await  DefaultCacheManager().getSingleFile(imageUrl);
    bool result = await WallpaperManagerFlutter().setWallpaper(file, location);
    if (result) {
      Get.snackbar('Wall Applied', 'New wall is applied\nShow support to developer.');
    } else {
      Get.snackbar('No New Wall', 'Could not apply new wall\nSome error occurred\nPlease retry');
    }
  }
  Future<void> setEditedWall(GlobalKey boundaryKey) async {
    try {
      // 1️⃣ Grab the RenderRepaintBoundary
      final boundary = boundaryKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar('Error', 'Could not capture the edit.');
        return;
      }

      // 2️⃣ Capture an image at high resolution (adjust ratio if needed)
      final ui.Image uiImage = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
      await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // 3️⃣ Save PNG to a temp file
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/JWalls_edited_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // 4️⃣ Set as wallpaper (both screens)
      final ok = await WallpaperManagerFlutter()
          .setWallpaper(file, WallpaperManagerFlutter.bothScreens);

      Get.snackbar(
        ok ? 'Wall Applied' : 'Failed',
        ok
            ? 'Your personalised wall is applied!'
            : 'Couldn’t set wall, please try again.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    }
  }
}