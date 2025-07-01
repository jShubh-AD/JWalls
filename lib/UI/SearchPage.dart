import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/ViewImage.dart';
import 'package:walpy/Widgets/TextInput.dart';
import '../Get_Controller/FeatchApi.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  static const BorderRadius borderRadius24 = BorderRadius.all(Radius.circular(24));

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiCall fetchWalls = Get.find<ApiCall>();
  Set<String> likedWallpapers = {};

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InputText(
          controller: fetchWalls.searchController,
          onSubmitted: (value) {
            fetchWalls.searchPageNum = 1;
            fetchWalls.searchApi(search: fetchWalls.searchController.text);
          },
        ).paddingOnly(left: 20, right: 20, bottom: 10),
        Obx(() {
            // Show a central loading indicator if fetching the first page
            if (fetchWalls.isLoading.value && fetchWalls.searchPhotos.isEmpty && fetchWalls.searchPageNum == 1) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }else if(fetchWalls.noImageFound.value){
              return Expanded(
                child: Center(
                    child: Text('No image for "${fetchWalls.searchController.text}" , try something else.')),
              );
            }
            else {
              return Expanded(
                child: MasonryGridView.count(
                  controller: fetchWalls.searchScrollController,
                  itemCount: fetchWalls.searchPhotos.length + (fetchWalls.isPagination.value ? 1 : 0),
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  itemBuilder: (context, index) {
                    double ht = index % 2 == 0 ? 200 : 250;
                    if (index == fetchWalls.searchPhotos.length){
                      return fetchWalls.isPagination.value ? Container(
                          height: ht,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.grey, borderRadius: SearchPage.borderRadius24),
                          child: Center(child: CircularProgressIndicator())): SizedBox.shrink();
                    }
                    final searchWalls = fetchWalls.searchPhotos[index];
                    final urls = searchWalls.urls!;
                    return Stack(
                      children: [ Container(
                          height: ht,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: SearchPage.borderRadius24),
                          child: ClipRRect(
                            borderRadius: SearchPage.borderRadius24,
                            child: GestureDetector(
                              onTap:  (){
                                Get.to( () => ViewImage(
                                  imageUrl: urls.full!,
                                  id: searchWalls.id!,
                                  //blurHash:  searchWalls.blurHash! ,)
                                ));
                              },
                              child: Hero(
                                tag: searchWalls.id!,
                                child: CachedNetworkImage(
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                imageUrl: urls.small!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                                ),
                                ),
                              ),
                            ),
                        ),
                      ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (likedWallpapers.contains(searchWalls.id!)) {
                                  likedWallpapers.remove(searchWalls.id!);
                                } else {
                                  likedWallpapers.add(searchWalls.id!);
                                }
                              });
                            },
                            //borderRadius: BorderRadius.circular(24),
                            child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5)
                                ),
                                child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 25, end: likedWallpapers.contains(searchWalls.id!) ?  27: 25),
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    builder: (context, size, child) {
                                      return Icon(
                                        likedWallpapers.contains(searchWalls.id!)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: likedWallpapers.contains(searchWalls.id!)
                                            ? Colors.red
                                            : Colors.white,
                                        size: size,
                                      );
                                    }
                                )
                            ),
                          ),
                        )
                    ]);

                  },
                ).paddingSymmetric(horizontal: 5),
              );
            }
          },
        ),
      ],
              ),
    );
  }
}