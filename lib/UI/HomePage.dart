import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:walpy/UI/ViewImage.dart';
import 'package:walpy/features/fav/data/fav-model.dart';
import 'package:walpy/features/fav/data/hive_service.dart';

import '../Get_Controller/FeatchApi.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  static const BorderRadius borderRadius24 = BorderRadius.all(
    Radius.circular(10),
  );

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin {
  final ApiCall fetchWalls = Get.find<ApiCall>();
  final FavService favService = FavService();

  @override
  bool get wantKeepAlive => true;

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final darkMode = isDarkMode(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notif) {
        // Trigger only on user‑initiated scrolling
        if (notif is ScrollUpdateNotification &&
            notif.metrics.pixels >=
                notif.metrics.maxScrollExtent - 400 && // 300 px from bottom
            !fetchWalls.isPagination.value &&
            !fetchWalls.isLoading.value &&
            fetchWalls.hasMore.value) {
          fetchWalls.isPagination.value = true;
          fetchWalls.homPageNum++;
          fetchWalls.fetchApi();
        }
        return false; // allow other handlers to receive the event
      },

      child: Obx(() {
        if (fetchWalls.isLoading.value && fetchWalls.photos.isEmpty) {
          return Center(child: CircularProgressIndicator(color: darkMode ? Colors.white : Colors.black ));
        }
        if (fetchWalls.photos.isEmpty) {
          return Center(child: Text('No walls found'));
        }

        return MasonryGridView.count(
          //  controller: fetchWalls.scrollController,
          itemCount: fetchWalls.photos.length,
          // extra for loader
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,

          itemBuilder: (context, index) {
            final wallpaper = fetchWalls.photos[index];
            final url = wallpaper.urls!;
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: index.isEven ? 180 : 250,
                  child: ClipRRect(
                    borderRadius: Homepage.borderRadius24,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ViewImage(
                            imageUrl: url.full!,
                            id: wallpaper.id!,
                            avtar: wallpaper.avatar!.medium,
                            smallUrl: url.small!,
                            userName: wallpaper.userName,
                            name: wallpaper.name,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        fadeInDuration: Duration.zero,
                        imageUrl: url.small!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Container(color: Colors.grey.shade100);
                        },
                        /*errorWidget: (build, url, error) => Container(
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off, color: Colors.black45),
                              const SizedBox(height: 4),
                              Text(
                                'No connection',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.black45),
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
                  child: ValueListenableBuilder<Box<FavModel>>(
                    valueListenable: favService.listenableFor(wallpaper.id!),
                    builder: (BuildContext context, value, Widget? child) {
                      final liked = favService.contains(wallpaper.id!);
                      return InkWell(
                        onTap: () async => favService.toggle(
                          FavModel(
                            id: wallpaper.id!,
                            bytes: await urltoUnit8(url.smallS3!),
                            avtar: wallpaper.avatar!.medium!,
                          ),
                        ),
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : Colors.white,
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
      }),
    );
  }

  Future urltoUnit8(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final bytes = await file.readAsBytes();
    return bytes;
  }
}
