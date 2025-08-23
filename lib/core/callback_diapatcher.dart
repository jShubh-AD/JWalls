import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../data/Models/Wallpapers.dart';
import 'http_const/api_const.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('wallpaper_channel');


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await _setWallpaperBackground(inputData);
  });
}

/// Main wallpaper setting function with optimizations
Future<bool> _setWallpaperBackground(Map<String, dynamic>? inputData) async {
  final int maxRetries = 1;
  final int timeoutSeconds = 20;

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      print('Wallpaper change attempt $attempt/$maxRetries');

      // 1. Fetch wallpaper data with timeout
      final wallpaper = await _fetchRandomWallpaper(timeoutSeconds);
      if (wallpaper == null) {
        print('Failed to fetch wallpaper data');
        continue;
      }
      // 2. Download and set wallpaper
      final success = await _setWallpaperNative(wallpaper);

      if (success) {
        print('Wallpaper set successfully on attempt $attempt');
        return true;
      }

    } catch (e) {
      print('Attempt $attempt failed: $e');

      // Wait before retry (exponential backoff)
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }
  print('All attempts failed to set wallpaper');
  return false;
}

/// Fetch random wallpaper with better error handling
Future<String?> _fetchRandomWallpaper(int timeoutSeconds) async {
  try {
    print('set random wallpaper called');
    final url = 'https://api.unsplash.com/photos/random${ApiConst.key}&query=wallpapers';
    print('Fetching wallpaper from: $url');

    final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => throw Exception('API request timeout')
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> wallData = jsonDecode(response.body);
      final wallpaper = Wallpapers.fromJson(wallData);

      if (wallpaper.urls?.full == null) {
        throw Exception('Invalid wallpaper URL received');
      }
      final String fullUrl =  wallpaper.urls!.full!;

      print('Wallpaper URL: ${wallpaper.urls!.full}');
      return fullUrl;
    } else {
      throw HttpException('API request failed with status: ${response.statusCode}');
    }

  } catch (e) {
    print('Error fetching wallpaper: $e');
    return null;
  }
}

/// Download image and set wallpaper with optimizations
Future<bool> _downloadAndSetWallpaper(String fullUrl) async {
  File? tempFile;
  print('download & set wall paper called');

  try {
    // Create unique temp file
    final dir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/JWalls_autoWall_$timestamp.jpg';
    tempFile = File(filePath);

    print('Downloading image to: $filePath');

    // Download with timeout and progress tracking
    final imageResponse = await http.get(Uri.parse(fullUrl));

    if (imageResponse.statusCode == 200) {

      // Write to file
      await tempFile.writeAsBytes(imageResponse.bodyBytes);

      // Verify file was written correctly
      if (!await tempFile.exists() || await tempFile.length() == 0) {
        throw Exception('Failed to save image file');
      }

      // Set wallpaper with timeout

     // final wallSet = await compute(_handelSetwall, tempFile );

      final bool  isSet = await WallpaperManagerFlutter()
          .setWallpaper(tempFile, 3)
          .timeout(Duration(seconds: 30));

      print('Wallpaper set successfully');
      return isSet;

    } else {
      print('Image download failed with status: ${imageResponse.statusCode}');
      throw HttpException('Image download failed with status: ${imageResponse.statusCode}');
    }

  } catch (e) {
    print('Error setting wallpaper: $e');
    return false;
  } finally {
    // Cleanup temp file
    if (tempFile != null) {
      _cleanupTempFile(tempFile);
    }
  }
}

/// Clean up temporary file safely
void _cleanupTempFile(File file) {
  Future.delayed(Duration(seconds: 10), () async {
    try {
      if (await file.exists()) {
        await file.delete();
        print('Temp file cleaned up: ${file.path}');
      }
    } catch (e) {
      print('Failed to cleanup temp file: $e');
    }
  });
}

/// Optional: Clean up old temp files on startup
Future<void> cleanupOldTempFiles() async {
  try {
    final dir = Directory.systemTemp;
    final files = await dir.list().toList();

    for (final entity in files) {
      if (entity is File && entity.path.contains('JWalls_autoWall_')) {
        final stats = await entity.stat();
        final age = DateTime.now().difference(stats.modified);

        // Delete files older than 1 hour
        if (age.inHours > 1) {
          await entity.delete();
          print('Deleted old temp file: ${entity.path}');
        }
      }
    }
  } catch (e) {
    print('Error cleaning old temp files: $e');
  }

}

Future<bool> _setWallpaperNative(String fullUrl) async {
  try {
    final result = await platform.invokeMethod("setWallpaper", {"imageUrl": fullUrl});
    return result == true;
  } catch (e) {
    print("Error invoking native wallpaper service: $e");
    return false;
  }
}

