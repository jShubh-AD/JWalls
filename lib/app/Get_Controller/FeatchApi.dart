import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:walpy/app/core/network/dio_client.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/network/api_const.dart';

class ApiCall extends GetxController {
  final RxList<Wallpaper> photos = <Wallpaper>[].obs;
  final RxList<Wallpaper> searchPhotos = <Wallpaper>[].obs;
  final dio = DioClient.instance;

  Rx<bool> isLoading = true.obs;
  Rx<bool> isOnline = false.obs;
  Rx<bool> isSearchLoading = false.obs;
  Rx<bool> noImageFound = false.obs;
  Rx<bool> hasMore = true.obs;
  int homPageNum = 1;
  int searchPageNum = 1;

  StreamSubscription? _isOnInternet;
  final TextEditingController searchController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    isOnline.value = false;
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
        final sWalls = await compute(heavyParsing, searchResponse.data['results']);
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
    }
  }

  // Future<void> fetchHomeWalls() async {
  //   try {
  //     if (homPageNum == 1) isLoading.value = true;
  //
  //     final response = await dio.performGet(
  //       url: ApiConst.fetchImages,
  //       params: {"per_page": ApiConst.per_page, "page": homPageNum},
  //     );
  //     if (response.statusCode == 200) {
  //       final parsedWalls = await compute(heavyParsing, response.data);
  //       if (homPageNum == 1) photos.clear();
  //       photos.addAll(parsedWalls);
  //
  //       // // Pre-cache a few images for smoother UI
  //       // WidgetsBinding.instance.addPostFrameCallback((_) {
  //       //   for (int j = 0; j < photos.length && j < 5; j++) {
  //       //     precacheImage(
  //       //       CachedNetworkImageProvider(photos[j].urls!.small!),
  //       //       Get.context!,
  //       //     );
  //       //   }
  //       // });
  //
  //     } else if (response.statusCode == 403) {
  //       Get.snackbar(
  //         'Limit exceeded',
  //         'You have exceeded you limit for this hour.\nPlease try after 1 hour: ${response.statusCode}',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red.withOpacity(0.8),
  //         colorText: Colors.white,
  //       );
  //     }
  //     isOnline.value = true;
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Something went wrong!',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red.withOpacity(0.8),
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //     // isPagination.value = false;
  //   }
  // }

  Future<void> fetchSingleWall() async {
    Workmanager();
  }

  static Future<List<Wallpaper>> heavyParsing(dynamic responseBody) async {
    return Wallpaper.fromJsonList(responseBody);
  }
}
