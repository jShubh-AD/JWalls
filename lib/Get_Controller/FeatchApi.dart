import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:walpy/UI/gallery_page.dart';
import 'package:walpy/core/http_const/api_const.dart';
import 'package:walpy/data/DataSource/user_datasource.dart';
import 'package:walpy/data/Models/UserModel.dart';
import '../UI/HomePage.dart';
import '../UI/SearchPage.dart';
import '../UI/Settings.dart';
import '../data/Models/Wallpapers.dart';
import '../features/fav/view/fav_page.dart';


class ApiCall extends GetxController {
  final RxList<Wallpapers> photos = <Wallpapers>[].obs;
  final RxList<Wallpapers> searchPhotos = <Wallpapers>[].obs;

  Rx<bool> isLoading = true.obs;
  Rx<bool> isOnline = false.obs;
  Rx<bool> isPagination = false.obs;
  Rx<bool> isSearchLoading =true.obs;
  Rx<bool> noImageFound = false.obs;
  Rx<bool> hasMore = true.obs;
  int homPageNum = 1;
  int searchPageNum = 1;

  StreamSubscription? _isOnInternet;
  final TextEditingController searchController = TextEditingController();
  RxInt selectedIndex = 0.obs;

  final List<GlobalKey<NavigatorState>> navigatorKeys = List.generate(4, (index) => GlobalKey<NavigatorState>(),);

  final List<Widget> pages = [
    const Homepage(),
    const GalleryPage(),
    const FavPage(),
    const Settings(),
  ];


  @override
  void onInit() {
    super.onInit();
    fetchApi();
    _isOnInternet = InternetConnection().onStatusChange.listen((event){
      if(event == InternetStatus.connected){
        isOnline.value = true;
        if(photos.isEmpty && !isLoading.value){
          fetchApi();
        }
      }
      else{
        isOnline.value = false;
      }
    });
  }


  @override
  void onClose(){
    _isOnInternet!.cancel();
    searchController.clear();
    super.onClose();
  }

  void searchApi({required String search})async{
    print('search api called for $search and page $searchPageNum');
    String searchUrl= '${ApiConst.searchWall.baseUrl()}${ApiConst.key}&per_page=19&page=$searchPageNum&query=$search';
    try{
      if (searchPageNum == 1) {
        isSearchLoading.value = true;
        searchPhotos.clear();
      }
      final searchResponse = await http.get(Uri.parse(searchUrl));
      if (searchResponse.statusCode == 200) {
        final Map<String, dynamic> sData = jsonDecode(searchResponse.body);
        final List<dynamic> results = sData['results'];

        if(results.isEmpty && searchPageNum ==1){
          noImageFound.value = true;
        }else{
          noImageFound.value = false;
        }
        final sWalls = await compute(heavySearch, results);
        searchPhotos.addAll(sWalls);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int j = 0; j < searchPhotos.length && j < 5; j++) {
            precacheImage(CachedNetworkImageProvider(searchPhotos[j].urls!.small!), Get.context!);
          }
        });
      }
     else  {
        Get.snackbar(
          'Error',
          'Server error: ${searchResponse.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
      isOnline.value = true;
    } on SocketException {
      Get.snackbar(
        'No Internet',
        'Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSearchLoading.value = false;
      isPagination.value = false;
    }
  }

  Future<void> fetchApi() async {
    print('fetch api called page $homPageNum');
    String url = '${ApiConst.fetchImageId.baseUrl()}${ApiConst.key}&per_page=20&page=$homPageNum';
    print(url);
    try {
      if (homPageNum == 1) {isLoading.value = true;}
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final parsedWalls = await compute(heavyTask, response.body);

        if (homPageNum == 1) {
          photos.clear(); // Clear on first page only
        }

        final existingIds = photos.map((e) => e.id).toSet();
        final uniquePhotos = parsedWalls.where((w) => !existingIds.contains(w.id)).toList();
        photos.addAll(uniquePhotos);

        // Pre-cache a few images for smoother UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int j = 0; j < photos.length && j < 5; j++) {
            precacheImage(CachedNetworkImageProvider(photos[j].urls!.small!), Get.context!);
          }
        });

      } else {
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

      isOnline.value = true;
    } on SocketException {
      Get.snackbar(
        'No Internet',
        'Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isPagination.value = false;
    }
  }

  static Future<List<Wallpapers>> heavyTask(String responseBody) async{
    List<Wallpapers> wallpaper = <Wallpapers>[];
    List<dynamic> data = jsonDecode(responseBody);
    for (Map i in data) {
     wallpaper.add(Wallpapers.fromJson(i));
    }
    return wallpaper;
  }
  static Future<List<Wallpapers>> heavySearch(List<dynamic> responseBody) async{
    List<Wallpapers> wallpaper = <Wallpapers>[];
    wallpaper = responseBody.map((e)=> Wallpapers.fromJson(e)).toList();
    return wallpaper;
  }
}