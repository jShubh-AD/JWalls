import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walpy/app/Widgets/wall.dart';
import 'package:walpy/app/core/app_errors/app_errors.dart';
import 'package:walpy/app/core/const/app_const.dart';
import 'package:walpy/app/modules/home/presentation/bloc/home_bloc.dart';
import '../../../fav/data/hive_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>{
    // with AutomaticKeepAliveClientMixin { todo: don't remove this cmt maybe helpful for remembering scroll position
  final FavService favService = FavService();

  // @override
  // bool get wantKeepAlive => true; todo: don't remove this cmt maybe helpful for remembering scroll position

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context); todo: don't remove this cmt maybe helpful for remembering scroll position
    final darkMode = isDarkMode(context);
    return BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state){

          if(state is HomeLoading){
            return Center(
              child: CircularProgressIndicator(
                color: darkMode ? Colors.white : Colors.black
              )
            );
          }

          if(state is HomeLoaded){
            final walls = state.walls;
            return CustomScrollView(
              slivers: [
                // todo: add sliverAppBar with horizontal scroll for categories
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppConst.yAxisSpacing,
                    crossAxisSpacing: AppConst.xAxisSpacing,
                    childCount: walls.length +1,
                    itemBuilder: (context, index){
                      return Wall(index, wallInfo: walls[index]);
                    },
                  ),
                )
              ],
            );
          }

          if(state is HomeError){
            final String error = state.message;
              return Center(
                child: Text(error),
              );
          }
          return SizedBox.shrink();
        }
    );
      // MasonryGridView.count(
      //   //  controller: fetchWalls.scrollController,
      //   itemCount: fetchWalls.photos.length,
      //   // extra for loader
      //   crossAxisCount: 2,
      //   mainAxisSpacing: 8,
      //   crossAxisSpacing: 8,
      //
      //   itemBuilder: (context, index) {
      //     final wallpaper = fetchWalls.photos[index];
      //     final url = wallpaper.urls!;
      //     return Stack(
      //       children: [
      //         SizedBox(
      //           width: double.infinity,
      //           height: index.isEven ? 180 : 250,
      //           child: ClipRRect(
      //             borderRadius: AppConst.borderRadius10,
      //             child: GestureDetector(
      //               onTap: () {
      //                 Get.to(
      //                   () => ViewImage(
      //                     hdImageUrl: url.full!,
      //                     id: wallpaper.id!,
      //                     profileImage: wallpaper.avatar!.medium,
      //                     lowQualityImageUrl: url.small!,
      //                     userName: wallpaper.userName,
      //                     name: wallpaper.name,
      //                   ),
      //                   transition: Transition.rightToLeft,
      //                 );
      //               },
      //               child: CachedNetworkImage(
      //                 fadeInDuration: Duration.zero,
      //                 imageUrl: url.small!,
      //                 fit: BoxFit.cover,
      //                 placeholder: (context, url) {
      //                   return Container(color: Colors.grey.shade100);
      //                 },
      //               ),
      //             ),
      //           ),
      //         ),
      //         Positioned(
      //           bottom: 10,
      //           right: 10,
      //           child: ValueListenableBuilder<Box<FavModel>>(
      //             valueListenable: favService.listenableFor(wallpaper.id!),
      //             builder: (BuildContext context, value, Widget? child) {
      //               final liked = favService.contains(wallpaper.id!);
      //               return InkWell(
      //                 onTap: () async => favService.toggle(
      //                   FavModel(
      //                     id: wallpaper.id!,
      //                     bytes: await urltoUnit8(url.small!),
      //                     avtar: wallpaper.avatar!.medium!,
      //                   ),
      //                 ),
      //                 child: Icon(
      //                   liked ? Icons.favorite : Icons.favorite_border,
      //                   color: liked ? Colors.red : Colors.white,
      //                   size: 25,
      //                   weight: 0.1,
      //                 ),
      //               );
      //             },
      //           ),
      //         ),
      //       ],
      //     );
      //   },
      // ).paddingSymmetric(horizontal: 5);
  }

  Future urltoUnit8(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final bytes = await file.readAsBytes();
    return bytes;
  }
}
