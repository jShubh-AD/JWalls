import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

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
import 'package:walpy/UI/portFolio.dart';
import 'package:walpy/Widgets/FloatingButtons.dart';
import 'package:walpy/features/fav/data/fav-model.dart';
import 'package:walpy/features/fav/data/hive_service.dart';

import '../Widgets/SliderWidget.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({
    super.key,
    this.userName,
    this.smallUrl,
    this.imageUrl,
    this.imageBytes,
    this.name,
    this.avtar,
    required this.id,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? smallUrl;
  final String id;
  final String? avtar;
  final String? userName;
  final String? name;

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

    // Use low-quality image initially
    // currentImageProvider = CachedNetworkImageProvider(widget.smallUrl!); // Replace with your small URL

    // Preload full-quality and update when ready
    ImageProvider fullImage;
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      fullImage = CachedNetworkImageProvider(widget.imageUrl!);
    } else {
      fullImage = MemoryImage(widget.imageBytes!);
    }
    fullImage
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((_, __) {
            if (mounted) {
              setState(() {
                currentImageProvider = fullImage;
              });
            }
          }),
        );
  }

  final GlobalKey _previewController = GlobalKey();
  late ImageProvider currentImageProvider = CachedNetworkImageProvider(
    widget.smallUrl!,
  );
  bool isEdit = false;
  double blurValue = 0;
  bool isLike = false;
  bool _isSettingWall = false;

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isEdit
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ///  Set wall FAB:
                FloatingActionButton(
                  heroTag: null,
                  splashColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                  onPressed: _isSettingWall
                      ? null // disable while busy
                      : () async {
                          setState(() => _isSettingWall = true);

                          //await Future.delayed(const Duration(seconds: 2));

                          try {

                            await setEditedWall(_previewController);

                            Get.snackbar(
                              'Wall Applied!',
                              'Enjoy your new wall.',
                            );
                          } catch (e) {
                            Get.snackbar('Could not apply wall', 'Error: $e');
                          } finally {
                            if (mounted) {
                              setState(() => _isSettingWall = false);
                            }
                          }
                        },
                  child: _isSettingWall
                      ? const SizedBox(
                          key: ValueKey('loader'),
                          height: 32,
                          width: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(
                          Icons.done,
                          key: ValueKey('done'),
                          size: 24,
                          color: Colors.black,
                        ),
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
                    print(widget.userName);
                    Get.to(() => Portfolio(
                        userName: widget.userName!
                    ),transition: Transition.rightToLeft,

                    );
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
              imageProvider: currentImageProvider,
              minScale: PhotoViewComputedScale.covered,
              maxScale: PhotoViewComputedScale.covered,
              enableRotation: false,
              initialScale: PhotoViewComputedScale.covered,
              strictScale: true,
              loadingBuilder: (context, event) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
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

  Future<void> setEditedWall(GlobalKey boundaryKey) async {
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
        '${tempDir.path}/JWalls_edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // 4️⃣ Set as wallpaper (both screens)
    final ok = await WallpaperManagerFlutter().setWallpaper(
      file,
      WallpaperManagerFlutter.bothScreens,
    );
    await file.delete();
  }
}
