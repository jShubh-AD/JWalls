import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'Get_Controller/FeatchApi.dart';
import 'UI/Home.dart';
import 'core/Theme/SystemTheme.dart';
import 'features/fav/data/fav-model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
