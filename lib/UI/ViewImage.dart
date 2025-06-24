import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walpy/Get_Controller/SetWallpaper.dart';
import 'package:walpy/Widgets/FloatingButtons.dart';

import '../Widgets/SliderWidget.dart';

class ViewImage extends StatefulWidget {
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
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  final GlobalKey _previewController = GlobalKey();
  bool isEdit = false;
  bool isLike = false;
  double blurValue = 0;
  @override
  Widget build(BuildContext context) {
    final SetWallpaper setWallpaper = Get.put(SetWallpaper());
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isEdit ? null :
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            splashColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            onPressed: (){ (blurValue > 0) ? setWallpaper.setEditedWall(_previewController)
              :setWallpaper.setWall(imageUrl: widget.imageUrl);
            }, child: Icon(Icons.done,color: Colors.black,),).paddingOnly(bottom: 10),
          FloatingActionButton(
            splashColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() {
                isLike = !isLike;
              });
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 25, end: isLike ? 30 : 25),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              builder: (context, size, child) {
                return Icon(
                  isLike ? Icons.favorite : Icons.favorite_border,
                  color: isLike ? Colors.red : Colors.black,
                  size: size,
                );
              },
            ),
          ).paddingOnly(bottom: 10),
          FloatingActionButton(
              splashColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              onPressed: (){}, child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(widget.authorUrl),
          ),
          ).paddingOnly(bottom: 10),

          FloatingButtons(
            edit:  Icon(Icons.edit,color: Colors.black,),
            editPressed: () {setState(() {
              isEdit = !isEdit;
            });},
            download: Icon(Icons.download,color: Colors.black,),
            downloadPressed: () {(blurValue > 0) ? downloadEditedToGallery() : downloadToGallery(widget.imageUrl);},
            info: Icon(Icons.info_outline,color: Colors.black,),
            infoPressed: () {  },
          )
        ],
      ).paddingOnly(bottom: 15),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: RepaintBoundary(
        key: _previewController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
                tag: widget.id,
                child: BlurHash(hash: widget.blurHash, imageFit: BoxFit.cover)),
            CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: Duration.zero,
            ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                  child: Container(color: Colors.transparent),
                ),
              ),
        
            // Show blur slider
            if (isEdit)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: BlurSliderWidget(
                  checkPressed: () {setState(() {
                    isEdit = false;
                  });},
                  closePressed: () {
                    setState(() {
                      blurValue = 0;
                      isEdit = false;
                    });
                  },
                  value: blurValue,
                  onChanged: (val) {
                    setState(() {
                      blurValue = val;
                    });
                  },
                ),
              )
          ],
        ),
      )
    );
  }
   captureBlurredImage() async {
    try {
      RenderRepaintBoundary boundary =
      _previewController.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing the wall: $e");
      return null;
    }
  }
  Future<void> downloadEditedToGallery() async {
    final bytes = await captureBlurredImage();
    if (bytes == null) return;

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: 'JWalls_Edited_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result['isSuccess']) {
      Get.snackbar('Saved', 'Edited wall saved to gallery.');
    } else {
      Get.snackbar('Failed', 'Could not save wall.');
    }
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
      final results = ImageGallerySaverPlus.saveImage(
          imageBytes,
        quality: 100,
        name: "JWalls_here_"'${DateTime.now().millisecondsSinceEpoch}'
      );
      print(results);
      if(results != null){
        Get.snackbar('Image saved', 'Image saved in gallery\nShow your support to dev.');
      }else{
        Get.snackbar('Something went wrong', '');
      }

    }catch(e){
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }
}