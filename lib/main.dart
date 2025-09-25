import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'Get_Controller/FeatchApi.dart';
import 'Get_Controller/settings_controller.dart';
import 'UI/Home.dart';
import 'core/Theme/SystemTheme.dart';
import 'core/callback_diapatcher.dart';
import 'core/shared_preferences.dart';
import 'features/fav/data/fav-model.dart';


Future<void> setupAutoWallpaperTask() async {
  try {
    // Cancel any existing tasks first
    await Workmanager().cancelByUniqueName("auto_wallpaper_task");

    // Get current constraints from SharedPreferences
    final prefs = SharePreferences();
    final constraints = await prefs.getAllConstraints();

    // Only register if auto switch is enabled
    if (constraints['autoSwitch'] == true) {
      await Workmanager().registerPeriodicTask(
        "auto_wallpaper_task",
        "autoWallpaperChanger",
        frequency: Duration(milliseconds: constraints['interval']),
        constraints: Constraints(
          networkType: constraints['wifiOnly'] == true
              ? NetworkType.unmetered
              : NetworkType.connected,
          requiresCharging: constraints['chargingOnly'] == true,
          requiresDeviceIdle: constraints['idleOnly'] == true,
          requiresBatteryNotLow: constraints['batteryLow'] != true,
        ),
        inputData: constraints, // Pass constraints to the background task
      );
      print('✅ Wallpaper task registered successfully');
      print('📋 Constraints: $constraints');
    } else {
      print('🔄 Auto switch disabled - no task registered');
    }
  } catch (e) {
    print('❌ Error setting up wallpaper task: $e');
  }
}

// Function to cancel WorkManager tasks
Future<void> cancelAutoWallpaperTask() async {
  try {
    await Workmanager().cancelByUniqueName("auto_wallpaper_task");
    print('🛑 Wallpaper task cancelled');
  } catch (e) {
    print('❌ Error cancelling wallpaper task: $e');
  }
}

// Clean up old temp files
void cleanupOldTempFiles() async {
  try {
    // Add your temp file cleanup logic here
    print('🧹 Cleaning up old temp files');
  } catch (e) {
    print('❌ Error cleaning temp files: $e');
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    // Initialize SharedPreferences first
    print('🔧 Initializing SharedPreferences...');
    await SharePreferences.init();

    // Initialize WorkManager
    print('🔧 Initializing WorkManager...');
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Clean up old temp files
    cleanupOldTempFiles();

    // Initialize the settings controller
    print('🔧 Initializing Settings Controller...');
    final settingsController = Get.put(WallpaperSettingsController());

    // Wait for controller to load preferences
    await Future.delayed(const Duration(milliseconds: 100));

    // Setup WorkManager task based on current settings
    print('🔧 Setting up auto wallpaper task...');
    await setupAutoWallpaperTask();

 /* final settingsController = Get.put(WallpaperSettingsController());

  print('Initialing workManager');
  cleanupOldTempFiles();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);


  print('calling setupAutoWallpaperTask');
  setupAutoWallpaperTask(settingsController);*/


  PaintingBinding.instance.imageCache
    ..maximumSize = 300
    ..maximumSizeBytes = 250 << 20;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(FavModelAdapter());
  await Hive.openBox<FavModel>('favorites');

  Get.put(ApiCall());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Home(),
    );
  }
}
