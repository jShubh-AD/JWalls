package com.example.walpy

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.net.URL

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wallpaper_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val imageUrl = call.argument<String>("imageUrl")
                if (imageUrl != null) {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val bitmap = BitmapFactory.decodeStream(URL(imageUrl).openStream())
                            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
                            wallpaperManager.setBitmap(bitmap)
                            runOnUiThread { result.success(true) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("WALLPAPER_ERROR", e.localizedMessage, null) }
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Image URL is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
