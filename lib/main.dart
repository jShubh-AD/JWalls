import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Get_Controller/FeatchApi.dart';
import 'UI/Home.dart';
import 'Theme/SystemTheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiCall());
  Get.put(NaviController());
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
      home: Home()
    );
  }
}
