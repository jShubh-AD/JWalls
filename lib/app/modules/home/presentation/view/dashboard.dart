import 'package:flutter/material.dart';
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

    return
       Scaffold(
         // todo: add FBA for random wall
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.white,
        //   onPressed: () async{
        //     controller.lottiController.repeat(period: Duration(seconds: 2));
        //     final imageUrl = await _fetchRandomWallpaper(20); // get URL
        //     if (imageUrl != null) {
        //       final result = await platform.invokeMethod("setWallpaper", {"imageUrl": imageUrl});
        //       (result)
        //           ? Get.snackbar('Wall Applied!', 'Enjoy your new wall.')
        //           : Get.snackbar('Error', 'Could not apply Wall, Please try again.');
        //
        //       print(result ? 'Wallpaper set' : 'Failed');
        //     }
        //     controller.lottiController.reset();
        // }, child: Obx((){
        //     return Lottie.asset(
        //         "assets/animations/random_loader.json",
        //       fit: BoxFit.contain,
        //       repeat: true,
        //       animate: controller.isRolling.value,
        //       controller: controller.lottiController
        //     );
        // }
        // )
        // ),
        // resizeToAvoidBottomInset: true,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          toolbarHeight: 46,
          actions: [
            GestureDetector(
              // todo: add navigation to search
              child: Icon(
                Icons.search,
                color: darkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 10,)
          ],
          leading: Container(
            padding: EdgeInsets.only(left: 10, bottom: 5),
            height: AppConst.getMaxHeight(context),
            width: AppConst.getMaxWidth(context),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: Image.asset('assets/images/JWalls_appBar_big.png')
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
              children: [
                const Homepage(),
                const Placeholder(),
                const Placeholder(),
                const Placeholder(),
                // const GalleryPage(),
                // const FavPage(),
                // const Settings(),
              ]
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
    );
  }

  // Future<String?> _fetchRandomWallpaper(int timeoutSeconds) async {
  //   try {
  //     print('set random wallpaper called');
  //     final url = 'https://api.unsplash.com/photos/random${ApiConst.key}&query=wallpapers';
  //     print('Fetching wallpaper from: $url');
  //
  //     final response = await http.get(Uri.parse(url)).timeout(
  //         Duration(seconds: timeoutSeconds),
  //         onTimeout: () => throw Exception('API request timeout')
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> wallData = jsonDecode(response.body);
  //       final wallpaper = OldWallpaperModle.fromJson(wallData);
  //
  //       if (wallpaper.urls?.full == null) {
  //         throw Exception('Invalid wallpaper URL received');
  //       }
  //       final String fullUrl =  wallpaper.urls!.full!;
  //
  //       print('Wallpaper URL: ${wallpaper.urls!.full}');
  //       return fullUrl;
  //     } else {
  //       throw HttpException('API request failed with status: ${response.statusCode}');
  //     }
  //
  //   } catch (e) {
  //     print('Error fetching wallpaper: $e');
  //     return null;
  //   }
  // }

}