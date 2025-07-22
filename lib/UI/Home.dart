import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walpy/Get_Controller/FeatchApi.dart';
import 'package:walpy/UI/SearchPage.dart';

import '../core/navigation.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final NaviController naviController = Get.put(NaviController());
  final ApiCall naviController = Get.find<ApiCall>();

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final darkMode = isDarkMode(context);

    return WillPopScope(
      onWillPop: () async {
        // The navigator inside the currently‑selected tab
        final navState = naviController
            .navigatorKeys[naviController.selectedIndex.value]
            .currentState;

        // 1️⃣ Pop inside the tab if we’re deeper than its root
        /* if (navState != null && navState.canPop()) {
          navState.maybePop();
          return false; // we handled it
        }*/

        // 2️⃣ Otherwise, jump back to Home tab
        if (naviController.selectedIndex.value != 0) {
          naviController.selectedIndex.value = 0;
          return false; // don’t exit the app
        }

        // 3️⃣ We’re already on Home/root → allow the app to close
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          toolbarHeight: 46,
          actions: [
            GestureDetector(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPage()));},
              child: Icon(
                Icons.search,
                color: darkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 10,)
          ],
          leading: Container(
            height: Get.height*0.15,
            width: Get.width*0.15,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: Image.asset('assets/images/JWalls_appBar_big.png'),
          ).paddingOnly(left: 10, bottom: 5),
          title: Text(
            'JWalls',
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        body: Obx(
          () => IndexedStack(
            index: naviController.selectedIndex.value,
            children: List.generate(naviController.pages.length, (index) {
              return Navigator(
                key: naviController.navigatorKeys[index],
                onGenerateRoute: (_) => MaterialPageRoute(
                  builder: (_) => naviController.pages[index],
                ),
              );
            }),
          ),
        ),
        bottomNavigationBar: Obx(
          () => NavigationBar(
            elevation: 0,
            height: height * 0.06,
            selectedIndex: naviController.selectedIndex.value,
            onDestinationSelected: (index) =>
                naviController.selectedIndex.value = index,
            backgroundColor: darkMode ? Colors.black : Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                tooltip: "Home Page",
                selectedIcon: Icon(
                  Icons.home,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                icon: Icon(
                  Icons.home_outlined,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                tooltip: "Search area",
                selectedIcon: Icon(
                  Icons.image,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                icon: Icon(
                  Icons.image_outlined,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                label: 'Gallery',
              ),
              NavigationDestination(
                tooltip: "Favourite zone",
                selectedIcon: Icon(
                  Icons.favorite,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                icon: Icon(
                  Icons.favorite_outline,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                label: 'Fav',
              ),
              NavigationDestination(
                tooltip: "Settings",
                selectedIcon: Icon(
                  Icons.settings,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                icon: Icon(
                  Icons.settings_outlined,
                  color: darkMode ? Colors.white : Colors.black,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}