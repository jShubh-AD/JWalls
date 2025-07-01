import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/HomePage.dart';
import 'package:walpy/UI/SearchPage.dart';
import 'package:walpy/UI/Settings.dart';

import '../features/fav/view/fav_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NaviController naviController = Get.put(NaviController());

  bool isDarkMode(BuildContext context) {
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
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Image.asset('assets/images/JWalls_appBar_big.png'),
        ).paddingOnly(left: 10, bottom: 5),
        title: Text(
          'JWalls',
          style: TextStyle(color: darkMode?Colors.white:Colors.black,fontWeight: FontWeight.w600, fontSize: 24),
        ),
      ),
      body: Obx(() => Stack(
        children: List.generate(naviController.pages.length, (index) {
          return Offstage(
            offstage: naviController.selectedIndex.value != index,
            child: Navigator(
              key: naviController.navigatorKeys[index],
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => naviController.pages[index],
              ),
            ),
          );
        }),
      )),
      bottomNavigationBar: Obx(
            () => NavigationBar(
          elevation: 0,
          height: height * 0.09,
          selectedIndex: naviController.selectedIndex.value,
          onDestinationSelected: (index) =>
          naviController.selectedIndex.value = index,
          backgroundColor: darkMode ? Colors.black : Colors.white,
          indicatorColor: darkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.home,color: darkMode?Colors.white:Colors.black), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.search,color: darkMode?Colors.white:Colors.black), label: 'Search'),
            NavigationDestination(
                icon: Icon(Icons.favorite,color: darkMode?Colors.white:Colors.black), label: 'Fav'),
            NavigationDestination(
                icon: Icon(Icons.settings,color: darkMode?Colors.white:Colors.black), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class NaviController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<GlobalKey<NavigatorState>> navigatorKeys = List.generate(
    4,
        (index) => GlobalKey<NavigatorState>(),
  );

  final List<Widget> pages = [
    const Homepage(),
    SearchPage(),
    const FavPage(),
    const Settings(),
  ];
}
