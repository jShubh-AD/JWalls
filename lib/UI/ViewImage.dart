import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:walpy/Get_Controller/FeatchApi.dart';
import 'package:walpy/Get_Controller/SetWallpaper.dart';
import 'package:walpy/Widgets/FloatingButtons.dart';
import 'package:walpy/features/fav/data/fav-model.dart';
import 'package:walpy/features/fav/data/hive_service.dart';
import '../Widgets/SliderWidget.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({
    super.key,
    this.imageUrl,
    this.imageBytes,
    required this.id,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final String id;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  final FavService favo = FavService();
 // final userCtrl = Get.find<ApiCall>();

  @override
  void initState() {
    super.initState();
   // userCtrl.loadUser(widget.id);
    final likeNow = favo.contains(widget.id);
    setState(() => isLike = likeNow);
  }

  final GlobalKey _previewController = GlobalKey();
  bool isEdit = false;
  double blurValue = 0;
  bool isLike = false;

  @override
  Widget build(BuildContext context) {
    final SetWallpaper setWallpaper = Get.put(SetWallpaper());
    print(widget.id);
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isEdit
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// Set wall FAB:
                FloatingActionButton(
                  heroTag: null,
                  splashColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () {
                    (blurValue > 0)
                        ? setWallpaper.setEditedWall(_previewController)
                        : (widget.imageUrl?.isNotEmpty ?? false)
                        ? setWallpaper.setWall(imageUrl: widget.imageUrl!)
                        : setFavWall(widget.imageBytes!);
                  },
                  child: Icon(Icons.done, color: Colors.black),
                ).paddingOnly(bottom: 10),

                /// Like FAB with setState logic to reBuild:
                FloatingActionButton(
                  heroTag:  null,
                  splashColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    late FavModel favM;

                    if (widget.imageUrl != null &&
                        widget.imageUrl!.isNotEmpty) {
                      final bytes = urlToUnit8(widget.imageUrl!);
                      favM = FavModel(id: widget.id, bytes: await bytes);
                    } else {
                      favM = FavModel(id: widget.id, bytes: widget.imageBytes!);
                    }
                    bool like = await favo.toggle(favM);
                    print('before setState isLike: $isLike');
                    setState(() {
                      isLike = like;
                      print('after setstate isLike:$isLike');
                    });
                  },
                  child: Icon(
                    isLike ? Icons.favorite : Icons.favorite_border,
                    color: isLike ? Colors.red : Colors.black,
                    size: isLike ? 30 : 25,
                  ),
                ).paddingOnly(bottom: 10),

                /// navigator to Author page with author image and User data FAB:
                ///
                ///
                FloatingActionButton(
                  heroTag: null,
                  splashColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () {
                    // Get.to(Portfolio(portfolio: userData));
                  },
                  child: Icon(Icons.person, color: Colors.black),
                ).paddingOnly(bottom: 10),
                /*  Obx(() {
                  final userData = userCtrl.user.value;
                  if (userData == null) {
                    return const Icon(Icons.person);
                  }
                  return FloatingActionButton(
                    splashColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Get.to(Portfolio(portfolio: userData));
                    },
                    child: userCtrl.isUserLoading.value
                        ? Icon(Icons.person, color: Colors.black)
                        : CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                              userData.profileImage!.medium!,
                            ),
                          ),
                  ).paddingOnly(bottom: 10);
                }),*/

                ///  Speed dial FAB(edit,download,info):
                FloatingButtons(
                  // edit -----------
                  edit: Icon(Icons.edit, color: Colors.black),
                  editPressed: () {
                    setState(() {
                      isEdit = !isEdit;
                    });
                  },
                  // download -----------
                  download: Icon(Icons.download, color: Colors.black),
                  downloadPressed: () {
                    (blurValue > 0)
                        ? downloadEditedToGallery()
                        : (widget.imageUrl?.isNotEmpty ?? false)
                        ? downloadToGallery(widget.imageUrl, null)
                        : downloadToGallery(null, widget.imageBytes!);
                  },
                  // info ---------
                  info: Icon(Icons.info_outline, color: Colors.black),
                  infoPressed: () {},
                ),
              ],
            ).paddingOnly(bottom: 15),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: RepaintBoundary(
        key: _previewController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 0),
                fadeOutDuration: Duration.zero,
              )
            else
              Image.memory(widget.imageBytes!, fit: BoxFit.cover),

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
                  checkPressed: () {
                    setState(() {
                      isEdit = false;
                    });
                  },
                  closePressed: () {
                    setState(() {
                      blurValue = 0.0;
                      print(blurValue);
                      isEdit = false;
                    });
                  },
                  value: blurValue,
                  onChanged: (val) {
                    setState(() {
                      blurValue = val;
                      print(blurValue);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?>? captureBlurredImage() async {
    try {
      RenderRepaintBoundary boundary =
          _previewController.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing the wall: $e");
      return null;
    }
  }

  /// Logic to download personalised image

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

  /// Logic for getting Unit8List(image bytes) from Url

  Future<Uint8List> urlToUnit8(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final imageBytes = await file.readAsBytes();
    return imageBytes;
  }

  /// Download logic for non-personalised image in pictures

  Future<void> downloadToGallery(String? imageUrl, Uint8List? imgBytes) async {
    final permission = await Permission.storage.request();
    if (!permission.isGranted && permission != permission.isLimited) {
      Get.snackbar(
        'Permission Denied.',
        'Please allow the storage permission to download.',
      );
      return;
    }
    try {
      late Uint8List? bytes;
      // Save to gallery
      (imageUrl?.isNotEmpty ?? false)
          ? bytes = await urlToUnit8(imageUrl!)
          : bytes = imgBytes;
      final results = ImageGallerySaverPlus.saveImage(
        bytes!,
        quality: 100,
        name:
            "JWalls_here_"
            '${DateTime.now().millisecondsSinceEpoch}',
      );
      print(results);
      if (results != null) {
        Get.snackbar(
          'Image saved',
          'Image saved in gallery\nShow your support to dev.',
        );
      } else {
        Get.snackbar('Something went wrong', '');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }

  Future<void> setFavWall(Uint8List bytes) async {
    try {
      final location = WallpaperManagerFlutter.bothScreens;
      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/JWalls_fav_${DateTime.now().microsecondsSinceEpoch}.png",
      );
      file.writeAsBytes(bytes);
      final ok = await WallpaperManagerFlutter().setWallpaper(file, location);
      await file.delete();
      Get.snackbar(
        ok ? 'Wall Applied' : 'Failed',
        ok
            ? 'Your favorite wall is applied!'
            : 'Couldn’t set wall, please try again.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    }
  }
}
