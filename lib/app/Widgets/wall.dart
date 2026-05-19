import 'package:flutter/material.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';

import '../core/const/app_const.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Wall extends StatelessWidget {
  final int index;
  final Wallpaper wallInfo;
  const Wall(this.index,{
    super.key,
    required this.wallInfo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: index.isEven ? 180 : 250,
      child: ClipRRect(
        borderRadius: AppConst.borderRadius10,
        child: GestureDetector(
          onTap: () {},// todo: navigate to view image
          child: CachedNetworkImage(
            fadeInDuration: Duration.zero,
            imageUrl: wallInfo.urls?.small ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(color: Colors.grey.shade100);
            },
          ),
        ),
      ),
    );;
  }
}
