import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get/get.dart';
import 'package:walpy/Get_Controller/SetWallpaper.dart';
import 'package:walpy/Widgets/FloatingButtons.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({
    super.key,
    required this.imageUrl,
    required this.blurHash,
    required this.authorUrl,
    required this.id
  });

  final String imageUrl;
  final String blurHash;
  final String authorUrl;
  final String id;


  @override
  Widget build(BuildContext context) {
    final SetWallpaper setWallpaper = Get.put(SetWallpaper());
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            onPressed: (){setWallpaper.setWallpaper(imageUrl: imageUrl);
            }, child: Icon(Icons.done,color: Colors.black,),).paddingOnly(bottom: 10),

          FloatingActionButton(
            heroTag: null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            onPressed: (){},
            child: Icon(Icons.favorite_border,color: Colors.black,)).paddingOnly(bottom: 10),

          FloatingActionButton(
            heroTag: null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              onPressed: (){}, child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(authorUrl),
          ),
          ).paddingOnly(bottom: 10),

          FloatingButtons(
            edit:  Icon(Icons.edit,color: Colors.black,),
          onPressed: () { },
            download: Icon(Icons.download,color: Colors.black,),
            info: Icon(Icons.info_outline,color: Colors.black,),
          profilePressed: () {  },
          downloadPressed: () {  },
          infoPressed: () {  },
          )
        ],
      ).paddingOnly(bottom: 15),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Hero(
        tag: id,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BlurHash(hash: blurHash, imageFit: BoxFit.cover),
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: Duration.zero,
            ),
          ],
        ),
      )
    );
  }
}
