import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/FavPage.dart';
import 'package:walpy/UI/HomePage.dart';
import 'package:walpy/UI/SearchPage.dart';
import 'package:walpy/UI/Settings.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final NaviController naviController = Get.find<NaviController>();
      bool isDarkMode(BuildContext context){
    return Theme.of(context).brightness == Brightness.dark;
  }
  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final darkMode = isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          title: Text('Wally',
          style: TextStyle(fontWeight: FontWeight.w600),
          ),
      ),

      body: Obx(()=> naviController.pages[naviController.selectedIndex.value]),

      bottomNavigationBar: Obx(()=> NavigationBar(
        elevation: 0,
          height: height*0.09,
          selectedIndex: naviController.selectedIndex.value,
          onDestinationSelected: (index) => naviController.selectedIndex.value = index,
          backgroundColor: darkMode ? Colors.black : Colors.white,
          indicatorColor: darkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home,color: darkMode ? Colors.white : Colors.black), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search,color: darkMode ? Colors.white : Colors.black), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.favorite,color: darkMode ? Colors.white : Colors.black), label: 'Fav'),
            NavigationDestination(icon: Icon(Icons.settings,color: darkMode ? Colors.white : Colors.black), label: 'Settings')
          ]),
      )
    );
  }
}

class NaviController extends GetxController{
  Rx<int> selectedIndex = 0.obs;
  List<Widget> pages = [Homepage(), SearchPage(),FavPage(),Settings()];
}