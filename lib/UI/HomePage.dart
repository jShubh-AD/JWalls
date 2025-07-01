import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/ViewImage.dart';
import '../Get_Controller/FeatchApi.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  static const BorderRadius borderRadius24 = BorderRadius.all(
    Radius.circular(24),
  );

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin {
  final ApiCall fetchWalls = Get.find<ApiCall>();
  //final FavoriteController like = Get.put(FavoriteController());

  @override
  bool get wantKeepAlive => true;

  //bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (fetchWalls.isLoading.value && fetchWalls.photos.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (fetchWalls.photos.isEmpty) {
        return Center(child: Text('No walls found'));
      }

      return MasonryGridView.count(
        controller: fetchWalls.scrollController,
        itemCount:
            fetchWalls.photos.length - 1,
        // extra for loader
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,

        itemBuilder: (context, index) {
          final wallpaper = fetchWalls.photos[index];
          final url = wallpaper.urls!.smallS3!;
          double ht = index.isEven ? 200 : 250;
          return Stack(
            children: [
              Container(
                height: ht,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: Homepage.borderRadius24,
                  color: Colors.grey,
                ),
                child: ClipRRect(
                  borderRadius: Homepage.borderRadius24,
                  child: GestureDetector(
                    onTap: () {
                      print(wallpaper.id);
                      Get.to(
                        () => ViewImage(
                          imageUrl: wallpaper.urls!.full!,
                          id: wallpaper.id!,
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 0),
                      fadeOutDuration: const Duration(milliseconds: 0),
                      imageUrl: url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
              bottom: 10,
                right: 10,
                child:  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ),
                  )
              )
            ],
          );
        },
      ).paddingSymmetric(horizontal: 5);
    });
  }
}
