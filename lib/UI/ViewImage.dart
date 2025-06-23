import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
            downloadPressed: () {downloadToGallery(imageUrl);},
            info: Icon(Icons.info_outline,color: Colors.black,),
          profilePressed: () {  },
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
  Future<void> downloadToGallery (String imageUrl) async{
    final permission = await Permission.storage.request();
    if(!permission.isGranted && permission != permission.isLimited){
      Get.snackbar('Permission Denied.', 'Please allow the storage permission to download.');
      return;
    }
    try {
      // Get file from cached
     final file = await DefaultCacheManager().getSingleFile(imageUrl);

     // Read image bytes
      final imageBytes = await file.readAsBytes();
      // Save to gallery
      final results = ImageGallerySaverPlus.saveImage(imageBytes);
      print(results);
      if(results != null){
        Get.snackbar('Image saved', 'Image saved in gallery\n Show your support to dev.');
      }else{
        Get.snackbar('Something went wrong', '');
      }

    }catch(e){
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }
}
