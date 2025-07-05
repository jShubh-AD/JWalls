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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InputText(
            controller: fetchWalls.searchController,
            onSubmitted: _onSearchSubmitted,
          ).paddingOnly(left: 20, right: 20, bottom: 10),
          Expanded(
            child: Obx(() {
              // Show a central loading indicator if fetching the first page
              if (fetchWalls.isLoading.value &&
                  fetchWalls.searchPhotos.isEmpty &&
                  fetchWalls.searchPageNum == 1) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              } else if (fetchWalls.noImageFound.value) {
                return Center(
                  child: Text(
                    'No image for "${fetchWalls.searchController.text}" , try something else.',
                  ),
                );
              } else {
                return MasonryGridView.count(
                  controller: fetchWalls.searchScrollController,
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
                                    imageUrl: urls.full!,
                                    id: searchWalls.id!,
                                    avtar: searchWalls.avatar!.small!,
                                    smallUrl: urls.smallS3,
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                imageUrl: urls.smallS3!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Container(color: Colors.grey.shade50);
                                },
                                errorWidget: (build, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            ?.copyWith(color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ),
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
                                (BuildContext context, value, Widget? child) {
                                  final isLike = favService.contains(
                                    searchWalls.id!,
                                  );
                                  return InkWell(
                                    onTap: () async => favService.toggle(
                                      FavModel(
                                        id: searchWalls.id!,
                                        bytes: await urlToUint8(urls.smallS3!),
                                        avtar: searchWalls.avatar!.small!,
                                      ),
                                    ),
                                    child: Icon(
                                      isLike
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLike ? Colors.red : Colors.white,
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
        ],
      ),
    );
  }

  Future urlToUint8(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final bytes = await file.readAsBytes();
    return bytes;
  }
}
