import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/ViewImage.dart';
import 'package:walpy/Widgets/TextInput.dart';
import 'package:walpy/features/fav/data/fav-model.dart';
import 'package:walpy/features/fav/data/hive_service.dart';

import '../Get_Controller/FeatchApi.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const BorderRadius borderRadius24 = BorderRadius.all(
    Radius.circular(10),
  );

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? _debounce;
  final ApiCall fetchWalls = Get.find<ApiCall>();
  final FavService favService = FavService();

  void _onSearchSubmitted(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchWalls.searchPageNum = 1;
      fetchWalls.searchApi(search: value);
    });
  }

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        toolbarHeight: 46,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: Get.height * 0.15,
              width: Get.width * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset('assets/images/JWalls_appBar_big.png'),
            ),
            Text(
              'JWalls',
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InputText(
              controller: fetchWalls.searchController,
              onSubmitted: _onSearchSubmitted,
            ).paddingOnly(left: 20, right: 20, bottom: 10, top: 10),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notif) {
                  if (notif is ScrollUpdateNotification &&
                      notif.metrics.pixels >=
                          notif.metrics.maxScrollExtent - 300 &&
                      !fetchWalls.isSearchLoading.value &&
                      !fetchWalls.isPagination.value) {
                    fetchWalls.isPagination.value = true;
                    fetchWalls.searchPageNum++;
                    fetchWalls.searchApi(
                      search: fetchWalls.searchController.text,
                    );
                  }
                  return false;
                },
                child: Obx(() {
                  // Show a central loading indicator if fetching the first page
                  if (fetchWalls.isLoading.value &&
                      fetchWalls.searchPhotos.isEmpty &&
                      fetchWalls.searchPageNum == 1) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    );
                  } else if (fetchWalls.noImageFound.value) {
                    return Center(
                      child: Text(
                        'No image for "${fetchWalls.searchController.text}" , try something else.',
                      ),
                    );
                  } else {
                    return MasonryGridView.count(
                      itemCount: fetchWalls.searchPhotos.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemBuilder: (context, index) {
                        final searchWalls = fetchWalls.searchPhotos[index];
                        final urls = searchWalls.urls!;
                        return Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: index.isEven ? 180 : 250,
                              child: ClipRRect(
                                borderRadius: SearchPage.borderRadius24,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => ViewImage(
                                        imageUrl: urls.full,
                                        id: searchWalls.id!,
                                        avtar: searchWalls.avatar!.medium!,
                                        smallUrl: urls.small,
                                        userName: searchWalls.userName,
                                        name: searchWalls.name,
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    fadeInDuration: Duration.zero,
                                    imageUrl: urls.small!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) {
                                      return Container(
                                        color: Colors.grey.shade100,
                                      );
                                    },
                                   /* errorWidget: (build, url, error) =>
                                        Container(
                                          color: Colors.grey.shade300,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.wifi_off,
                                                color: Colors.black45,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'No connection',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.black45,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),*/
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: ValueListenableBuilder(
                                valueListenable: favService.listenableFor(
                                  searchWalls.id!,
                                ),
                                builder:
                                    (
                                      BuildContext context,
                                      value,
                                      Widget? child,
                                    ) {
                                      final isLike = favService.contains(
                                        searchWalls.id!,
                                      );
                                      return InkWell(
                                        onTap: () async => favService.toggle(
                                          FavModel(
                                            id: searchWalls.id!,
                                            bytes: await urlToUint8(
                                              urls.regular!,
                                            ),
                                            avtar: searchWalls.avatar!.medium!,
                                          ),
                                        ),
                                        child: Icon(
                                          isLike
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLike
                                              ? Colors.red
                                              : Colors.white,
                                          size: 25,
                                          weight: 0.1,
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ],
                        );
                      },
                    ).paddingSymmetric(horizontal: 5);
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future urlToUint8(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final bytes = await file.readAsBytes();
    return bytes;
  }
}
