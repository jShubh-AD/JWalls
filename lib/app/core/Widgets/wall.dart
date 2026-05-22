import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:walpy/app/core/app_routes/app_routes.dart';
import 'package:walpy/app/modules/favourite/data/favourite_model.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/view_image/presentation/pages/view_image_args.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/const/app_const.dart';

class Wall extends StatelessWidget {
  final int index;
  final Wallpaper? wallInfo;
  final FavouriteModel? favouriteWall;

  const Wall(this.index, {super.key, this.wallInfo, this.favouriteWall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: index.isEven ? 180 : 250,
      child: ClipRRect(
        borderRadius: AppConst.borderRadius10,
        child: GestureDetector(
          onTap: () {
            context.pushNamed(
              AppRoutes.view_image,
              extra: ViewImageArgs(
                wallInfo: wallInfo,
                favouriteWall: favouriteWall,
              ),
            );
          },
          child: CachedNetworkImage(
            fadeInDuration: Duration.zero,
            imageUrl: wallInfo?.urls?.small ?? favouriteWall?.urls?.small ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(color: Colors.grey.shade100);
            },
          ),
        ),
      ),
    );
    ;
  }
}
