import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:walpy/app/core/app_routes/app_routes.dart';
import 'package:walpy/app/core/utils/const/app_const.dart';
import 'package:walpy/app/core/utils/helpers/app_helpers.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/view_image/bloc/view_image_bloc.dart';
import 'package:walpy/app/modules/view_image/presentation/widgets/loading_fba.dart';
import '../../../../core/Widgets/FloatingButtons.dart';
import '../../../../core/Widgets/SliderWidget.dart';
import '../../../../core/Widgets/app_snackbar.dart';
import '../../../fav/data/fav-model.dart';
import '../../../fav/data/hive_service.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({super.key, this.imageBytes, required this.wallInfo});

  final Wallpaper wallInfo;
  final Uint8List? imageBytes;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  final FavService favo = FavService();

  @override
  void initState() {
    super.initState();
    // final likeNow = favo.contains(widget.wallInfo.id ?? "");
    // setState(() => isLike = likeNow);

    ImageProvider fullImage;
    if (widget.wallInfo.urls?.full != null) {
      fullImage = CachedNetworkImageProvider(widget.wallInfo.urls?.full ?? "");
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
    widget.wallInfo.urls?.small ?? "",
  );
  bool isLike = false;

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: BlocConsumer<ViewImageBloc, ViewImageState>(
        listener: (context, state) {
          if (state.showSnack) {
            AppSnackBar.show(
              context,
              title: state.title,
              message: state.message,
              isError: state.isError,
            );
          }
        },
        builder: (context, state) {
          if (state.editStatus == EditStatus.editing) {
            return SizedBox.shrink();
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LoadingFAB(
                loading: state.isSettingWall,
                child: const Icon(
                  Icons.now_wallpaper_rounded,
                  size: 28,
                  color: Colors.black,
                ),
                onPressed: () => context.read<ViewImageBloc>().add(
                  ViewImageSetWall(_previewController),
                ),
              ),
              AppConst.sizedBoxH10,

              // Like FBA
              FloatingActionButton(
                heroTag: null,
                splashColor: Colors.transparent,
                shape: AppConst.recBorderRadius24,
                backgroundColor: Colors.white,
                onPressed: () async {
                  late FavModel favM;
                  if (widget.wallInfo.urls?.full != null &&
                      widget.wallInfo.urls!.full!.isNotEmpty) {
                    final bytes = AppHelpers.urlToBytes(
                      widget.wallInfo.urls!.full!,
                    );
                    favM = FavModel(
                      id: widget.wallInfo.id ?? "",
                      bytes: await bytes,
                      avtar: widget.wallInfo.avatar?.large ?? "",
                    );
                  } else {
                    favM = FavModel(
                      id: widget.wallInfo.id ?? "",
                      bytes: widget.imageBytes!,
                      avtar: widget.wallInfo.avatar?.large ?? "",
                    );
                  }
                  bool like = await favo.toggle(favM);
                  // print('before setState isLike: $isLike');
                  setState(() {
                    isLike = like;
                    // print('after setstate isLike:$isLike');
                  });
                },
                child: Icon(
                  isLike ? Icons.favorite : Icons.favorite_border,
                  color: isLike ? Colors.red : Colors.black,
                  size: isLike ? 30 : 25,
                ),
              ),

              AppConst.sizedBoxH10,

              /// navigator to Author page with author image and User data FAB:
              FloatingActionButton(
                heroTag: null,
                splashColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.white,
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.portfolio,
                    queryParameters: {"userName": widget.wallInfo.userName},
                  );
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.transparent,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.wallInfo.avatar?.large ?? "",
                  ),
                ),
              ),

              AppConst.sizedBoxH10,

              ///  Speed dial FAB(edit,download,info):
              FloatingButtons(
                edit: Icon(Icons.edit, color: Colors.black),
                editPressed: () => context.read<ViewImageBloc>().add(EditingWall()),

                download: Icon(Icons.download, color: Colors.black),
                isDownloadLoading: state.isDownloading,
                downloadPressed: () => context.read<ViewImageBloc>().add(
                  DownloadWall(
                    boundaryKey: _previewController,
                    url: widget.wallInfo.urls?.full,
                    bytes: widget.imageBytes,
                  )),

                info: Icon(Icons.info_outline, color: Colors.black),
                infoPressed: () {},
              ),
            ],
          );
        },
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: Colors.white54,
              borderRadius: AppConst.borderRadius18,
              onPressed: () => context.pop(),
              child: const Icon(
                CupertinoIcons.back,
                size: 28,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: RepaintBoundary(
        key: _previewController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PhotoView(
              filterQuality: FilterQuality.high,
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

            BlocBuilder<ViewImageBloc, ViewImageState>(
              buildWhen: (prev, curr) => prev.blur != curr.blur,
              builder: (context, state) {
                print(("filter rebuild"));
                if (state.blur == 0.0) return const SizedBox.shrink();
                return Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: state.blur,
                      sigmaY: state.blur,
                    ),
                    child: Container(),
                  ),
                );
              },
            ),

            BlocBuilder<ViewImageBloc, ViewImageState>(
              buildWhen: (prev, curr) => prev.editStatus != curr.editStatus,
              builder: (context, state) {
                print(("slider rebuild"));
                if (state.editStatus != EditStatus.editing)
                  return const SizedBox.shrink();
                return Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: BlurSliderWidget(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<Uint8List?>? captureBlurredImage() async {
  //   try {
  //     RenderRepaintBoundary boundary =
  //         _previewController.currentContext!.findRenderObject()
  //             as RenderRepaintBoundary;
  //     final image = await boundary.toImage(pixelRatio: 3);
  //     final byteData = await image.toByteData(format: ImageByteFormat.png);
  //     return byteData?.buffer.asUint8List();
  //   } catch (e) {
  //     // print("Error capturing the wall: $e");
  //     return null;
  //   }
  // }

  /// -------------------------------------------------DOWNLOADS WALLS -------------------------------------------------------------------
  /// Logic to download personalised image

  // Future<void> downloadEditedToGallery() async {
  //   final bytes = await captureBlurredImage();
  //   if (bytes == null) return;
  //
  //   final result = await ImageGallerySaverPlus.saveImage(
  //     bytes,
  //     quality: 100,
  //     name: 'JWalls_Edited_${DateTime.now().millisecondsSinceEpoch}',
  //   );
  //
  //   if (result['isSuccess']) {
  //     // todo: show snack bar for edit saved in gallery
  //   } else {
  //     // todo: show snack bar for not saving edit in gallery
  //   }
  // }
  //
  // /// Download logic for non-personalised image in pictures
  //
  // Future<void> downloadToGallery(String? imageUrl, Uint8List? imgBytes) async {
  //   final permission = await Permission.storage.request();
  //   if (!permission.isGranted && permission != permission.isLimited) {
  //     // todo: show snack bar permission denied
  //     return;
  //   }
  //   try {
  //     late Uint8List? bytes;
  //     // Save to gallery
  //     (imageUrl?.isNotEmpty ?? false)
  //         ? bytes = await AppHelpers.getImageBytes(imageUrl!)
  //         : bytes = imgBytes;
  //     final results = ImageGallerySaverPlus.saveImage(
  //       bytes!,
  //       quality: 100,
  //       name:
  //           "JWalls_here_"
  //           '${DateTime.now().millisecondsSinceEpoch}',
  //     );
  //     // todo: show snack bar image saved
  //   } catch (e) {
  //     // todo: show snack bar of error
  //   }
  // }
}
