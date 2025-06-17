import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/ViewImage.dart';
import '../Get_Controller/FeatchApi.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
      static const BorderRadius borderRadius24 = BorderRadius.all(Radius.circular(24));

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin{
  final ApiCall fetchWalls = Get.find<ApiCall>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Obx(() {
        if (fetchWalls.isLoading.value && fetchWalls.photos.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (fetchWalls.photos.isEmpty) {
          return Center(child: Text('No walls found'));
        }

        return MasonryGridView.count(
          controller: fetchWalls.scrollController,
          itemCount: fetchWalls.photos.length + (fetchWalls.isPagination.value ? 1 : 0), // extra for loader
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,

          itemBuilder: (context, index) {
            double ht = index.isEven ? 200 : 250;
            if (index == fetchWalls.photos.length) {
              return fetchWalls.isPagination.value ? Container(
                  height: ht,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: Homepage.borderRadius24),
                  child: Center(child: CircularProgressIndicator())) : SizedBox.shrink();
            }
            final wallpaper = fetchWalls.photos[index];
            final url = wallpaper.urls!.small!;
            return Container(
                height: ht,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: Homepage.borderRadius24,
                  color: Colors.grey
                ),
                child: ClipRRect(
                  borderRadius: Homepage.borderRadius24,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ViewImage(
                        imageUrl: wallpaper.urls!.full!,
                        blurHash: wallpaper.blurHash!,
                        authorUrl: wallpaper.user!.profileImage!.medium!,
                        id: wallpaper.id!,
                      ));
                      },
                    child: Hero(
                      tag: wallpaper.id!,
                      child: CachedNetworkImage(
                      fadeInDuration: const Duration(milliseconds: 0),
                      fadeOutDuration: const Duration(milliseconds: 0),
                      imageUrl: url,
                      fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ),
            );
          },
        ).paddingSymmetric(horizontal: 5);
      })
    );
  }
}
