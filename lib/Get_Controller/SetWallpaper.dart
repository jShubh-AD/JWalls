import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class SetWallpaper extends GetxController{
  Future<void> setWallpaper({required String imageUrl}) async{
    int location = WallpaperManagerFlutter.bothScreens;
    var fileInfo =  await DefaultCacheManager().getFileFromCache(imageUrl);

    if (fileInfo != null) {
      print("✅ Image was found in cache: ${fileInfo.file.path}");
    } else {
      print("❌ Image not in cache, will be downloaded.");
    }

    File file = await  DefaultCacheManager().getSingleFile(imageUrl);
    bool result = await WallpaperManagerFlutter().setWallpaper(file, location);
    if (result) {
      Get.dialog(AlertDialog(content: Text('Enjoy your new wallpaper')));
    } else {
      Get.dialog(AlertDialog(content: Text('Some error occurred')));
    }
  }
}