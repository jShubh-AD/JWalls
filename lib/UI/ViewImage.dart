import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:walpy/Widgets/FloatingButtons.dart';
import 'package:walpy/features/fav/data/fav-model.dart';
import 'package:walpy/features/fav/data/hive_service.dart';
import '../Widgets/SliderWidget.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({
    super.key,
    this.smallUrl,
    this.imageUrl,
    this.imageBytes,
    this.avtar,
    required this.id,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? smallUrl;
  final String id;
  final String? avtar;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  final FavService favo = FavService();

  @override
  void initState() {
    super.initState();
    final likeNow = favo.contains(widget.id);
    setState(() => isLike = likeNow);
  }

  final GlobalKey _previewController = GlobalKey();
  bool isEdit = false;
  double blurValue = 0;
  bool isLike = false;

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(
          widget.imageUrl!,
       // maxWidth : (Get.width * 2).ceil(),
       // maxHeight: (Get.height *).ceil(),
      );
    } else {
      imageProvider = MemoryImage(widget.imageBytes!);
    }
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
                        ? setEditedWall(_previewController)
                        : (widget.imageUrl?.isNotEmpty ?? false)
                        ? setWall(imageUrl: widget.imageUrl!)
                        : setFavWall(widget.imageBytes!);
                  },
                  child: Icon(Icons.done, color: Colors.black),
                ).paddingOnly(bottom: 10),

                /// Like FAB with setState logic to reBuild:
                FloatingActionButton(
                  heroTag: null,
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
                      favM = FavModel(
                        id: widget.id,
                        bytes: await bytes,
                        avtar: widget.avtar!,
                      );
                    } else {
                      favM = FavModel(
                        id: widget.id,
                        bytes: widget.imageBytes!,
                        avtar: widget.avtar!,
                      );
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
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(widget.avtar!),
                  ),
                ).paddingOnly(bottom: 10),

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
            PhotoView(
              filterQuality: FilterQuality.low,
              imageProvider: imageProvider,
              minScale: PhotoViewComputedScale.covered,
              maxScale: PhotoViewComputedScale.covered,
              enableRotation: false,
              initialScale: PhotoViewComputedScale.covered,
              strictScale: true,
              loadingBuilder: (context, event) {
                return CachedNetworkImage(
                  imageUrl: widget.smallUrl!,
                  fit: BoxFit.cover,
                );
              },
            ),

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: Container(),
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

  /// -------------------------------------------------DOWNLOADS WALLS -------------------------------------------------------------------
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

  /// -------------------------------------------------SET WALLS -------------------------------------------------------------------

  /// ================= SET WALLPAPER ==============

  Future<void> setWall({required String imageUrl}) async {
    int location = WallpaperManagerFlutter.bothScreens;
    var fileInfo = await DefaultCacheManager().getFileFromCache(imageUrl);

    if (fileInfo != null) {
      print("✅ wall was found in cache: ${fileInfo.file.path}");
    } else {
      print("❌ wall not in cache, will be downloaded.");
    }

    File file = await DefaultCacheManager().getSingleFile(imageUrl);
    bool result = await WallpaperManagerFlutter().setWallpaper(file, location);
    if (result) {
      Get.snackbar(
        'Wall Applied',
        'New wall is applied\nShow support to developer.',
      );
    } else {
      Get.snackbar(
        'No New Wall',
        'Could not apply new wall\nSome error occurred\nPlease retry',
      );
    }
  }

  /// ================= SET PERSONALISED WALLPAPER ==============

  Future<void> setEditedWall(GlobalKey boundaryKey) async {
    try {
      // 1️⃣ Grab the RenderRepaintBoundary
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar('Error', 'Could not capture the edit.');
        return;
      }
      // 2️⃣ Capture an image at high resolution (adjust ratio if needed)
      final ui.Image uiImage = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // 3️⃣ Save PNG to a temp file
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/JWalls_edited_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // 4️⃣ Set as wallpaper (both screens)
      final ok = await WallpaperManagerFlutter().setWallpaper(
        file,
        WallpaperManagerFlutter.bothScreens,
      );
      await file.delete();

      Get.snackbar(
        ok ? 'Wall Applied' : 'Failed',
        ok
            ? 'Your personalised wall is applied!'
            : 'Couldn’t set wall, please try again.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    }
  }

  /// ================= SET FAV WALLPAPER ==============

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

/*if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                fadeInDuration: const Duration(milliseconds: 0),
                fadeOutDuration: Duration.zero,
                placeholder: (context, url) {
                  return (widget.smallUrl?.isNotEmpty ?? false )
                    ? CachedNetworkImage(imageUrl: widget.smallUrl!)
                      : Container(color: Colors.transparent);
                },
                errorWidget: (build, url, error) => Container(
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.black45),
                      const SizedBox(height: 4),
                      Text(
                        'No connection',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              )
            else
              Image.memory(widget.imageBytes!,),*/

/* (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: widget.imageUrl!,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (context, url) {
                        return (widget.smallUrl?.isNotEmpty ?? false)
                            ? CachedNetworkImage(imageUrl: widget.smallUrl!)
                            : Container(color: Colors.transparent);
                      },
                      errorWidget: (build, url, error) => Container(
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.black45),
                            const SizedBox(height: 4),
                            Text(
                              'No connection',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Image.memory(widget.imageBytes!),*/
