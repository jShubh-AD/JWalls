import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:walpy/app/core/app_routes/app_routes.dart';
import 'package:walpy/app/modules/favourite/presentation/pages/fav.dart';
import '../../../../core/utils/const/app_const.dart';
import 'home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final darkMode = isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        toolbarHeight: 46,
        actions: [
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.search),
            child: Icon(
              Icons.search,
              color: darkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(width: 10),
        ],
        leading: Container(
          padding: EdgeInsets.only(left: 10, bottom: 5),
          height: AppConst.getMaxHeight(context),
          width: AppConst.getMaxWidth(context),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          child: Image.asset('assets/images/JWalls_appBar_big.png'),
        ),
        title: Text(
          'JWalls',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (index != 0) {
            setState(() => index = 0);
            return false;
          }
          return true;
        },
        child: IndexedStack(
          index: index,
          children: const [
            Homepage(),
            FavouritePage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: height * 0.06,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
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
        ],
      ),
    );
  }
}
