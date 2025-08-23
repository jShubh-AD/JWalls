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
import 'features/fav/data/fav-model.dart';


void setupAutoWallpaperTask(WallpaperSettingsController controller) {

  final c = controller.constraints.value;

  Workmanager().registerPeriodicTask(
    "auto_wallpaper_task",
    "autoWallpaperChanger",
    frequency: c.interval,
    constraints: Constraints(
      networkType: c.wifiOnly ? NetworkType.unmetered : NetworkType.connected,
      requiresCharging: c.chargingOnly,
      requiresDeviceIdle: c.idleOnly,
      requiresBatteryNotLow: c.batteryLow,
    ),
  );
  print('Wallpaper task registered with dynamic constraints');
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = Get.put(WallpaperSettingsController());

  print('Initialing workManager');
  cleanupOldTempFiles();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);


  print('calling setupAutoWallpaperTask');
  setupAutoWallpaperTask(settingsController);


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
