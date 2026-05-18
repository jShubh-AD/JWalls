import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:walpy/app/core/network/dio_client.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../UI/Settings.dart';
import '../UI/gallery_page.dart';
import '../core/network/api_const.dart';
import '../data/Models/Wallpaper.dart';
import '../modules/fav/view/fav_page.dart';
import '../modules/home/homepage.dart';

class ApiCall extends GetxController {
  final RxList<Wallpaper> photos = <Wallpaper>[].obs;
  final RxList<Wallpaper> searchPhotos = <Wallpaper>[].obs;
  final dio = DioClient.instance;

  Rx<bool> isLoading = true.obs;
  Rx<bool> isOnline = false.obs;
  Rx<bool> isPagination = false.obs;
  Rx<bool> isSearchLoading = false.obs;
  Rx<bool> noImageFound = false.obs;
  Rx<bool> hasMore = true.obs;
  int homPageNum = 1;
  int searchPageNum = 1;

  StreamSubscription? _isOnInternet;
  final TextEditingController searchController = TextEditingController();
  RxInt selectedIndex = 0.obs;

  final List<GlobalKey<NavigatorState>> navigatorKeys = List.generate(
    4,
    (index) => GlobalKey<NavigatorState>(),
  );

  final List<Widget> pages = [
    const Homepage(),
    const GalleryPage(),
    const FavPage(),
    Settings(),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchApi();
    _isOnInternet = InternetConnection().onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        isOnline.value = true;
        if (photos.isEmpty && !isLoading.value) {
          fetchApi();
        }
      } else {
        isOnline.value = false;
      }
    });
  }

  @override
  void onClose() {
    _isOnInternet!.cancel();
    searchController.clear();
    super.onClose();
  }

  void searchApi({required String search}) async {
    print('search api called for $search and page $searchPageNum');
    try {
      if (searchPageNum == 1) {
        isSearchLoading.value = true;
        searchPhotos.clear();
      }
      final searchResponse = await dio.performGet(
          url: ApiConst.searchWall,
          params: {
            'per_page':ApiConst.per_page,
            'page':searchPageNum,
            'query':search
          });
      if (searchResponse.statusCode == 200) {
        final sWalls = await Wallpaper.fromJsonList(searchResponse.data['results']);
        searchPhotos.addAll(sWalls);

        searchPhotos.isEmpty
            ? noImageFound.value = true
            : noImageFound.value = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int j = 0; j < searchPhotos.length && j < 5; j++) {
            precacheImage(
              CachedNetworkImageProvider(searchPhotos[j].urls!.small!),
              Get.context!,
            );
          }
        });
      } else if (searchResponse.statusCode == 403) {
        Get.snackbar(
          'Limit exceeded',
          'You have exceeded you limit for this hour.\nPlease try after 1 hour: ${searchResponse.statusCode}',
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
    String url =
        '${ApiConst.fetchImages}${ApiConst.key}&per_page=20&page=$homPageNum';
    print(url);
    try {
      if (homPageNum == 1) {
        isLoading.value = true;
      }
      // final response = await http.get(Uri.parse(url));
      final response = await dio.performGet(
        url: ApiConst.fetchImages,
        params: {"per_page": ApiConst.per_page, "page": homPageNum},
      );
      if (response.statusCode == 200) {
        final parsedWalls = Wallpaper.fromJsonList(response.data);

        if (homPageNum == 1) photos.clear();

        final existingIds = photos.map((e) => e.id).toSet();
        final uniquePhotos = parsedWalls
            .where((w) => !existingIds.contains(w.id))
            .toList();
        photos.addAll(uniquePhotos);

        // Pre-cache a few images for smoother UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int j = 0; j < photos.length && j < 5; j++) {
            precacheImage(
              CachedNetworkImageProvider(photos[j].urls!.small!),
              Get.context!,
            );
          }
        });
      } else if (response.statusCode == 403) {
        Get.snackbar(
          'Limit exceeded',
          'You have exceeded you limit for this hour.\nPlease try after 1 hour: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
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

  Future<void> fetchSingleWall() async {
    Workmanager();
  }

  static Future<List<Wallpaper>> heavyTask(dynamic responseBody) async {
    List<Wallpaper> wallpaper = <Wallpaper>[];
    List<dynamic> data = jsonDecode(responseBody);
    for (Map i in data) {
      wallpaper.add(Wallpaper.fromJson(i));
    }
    return wallpaper;
  }
}
