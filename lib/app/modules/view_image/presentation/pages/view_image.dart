import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:walpy/app/core/app_routes/app_routes.dart';
import 'package:walpy/app/core/utils/const/app_const.dart';
import 'package:walpy/app/modules/favourite/data/favourite_model.dart';
import 'package:walpy/app/modules/home/data/wallaper_response_modle.dart';
import 'package:walpy/app/modules/view_image/bloc/view_image_bloc.dart';
import 'package:walpy/app/modules/view_image/presentation/widgets/loading_fba.dart';
import '../../../../core/Widgets/FloatingButtons.dart';
import '../../../../core/Widgets/SliderWidget.dart';
import '../../../../core/Widgets/app_snackbar.dart';
import '../../../favourite/data/local_datasource.dart';
import '../../../favourite/presentation/bloc/favourite_bloc.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({super.key, this.favouriteWall, required this.wallInfo});

  final Wallpaper? wallInfo;
  final FavouriteModel? favouriteWall;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  void initState() {
    super.initState();
    context.read<FavouriteBloc>().add(CheckIsLiked(widget.wallInfo?.id ?? ""));
    ImageProvider fullImage;
    if (widget.wallInfo?.urls?.full != null) {
      fullImage = CachedNetworkImageProvider(widget.wallInfo?.urls?.full ?? "");
    } else {
      fullImage = CachedNetworkImageProvider(
        widget.favouriteWall?.urls?.full ?? "",
      );
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
    widget.wallInfo?.urls?.small ?? "",
  );

  @override
  Widget build(BuildContext context) {
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
              BlocConsumer<FavouriteBloc, FavouriteState>(
                listenWhen: (prev, curr) =>
                    prev.showSnack != curr.showSnack && curr.showSnack,
                listener: (context, state) => AppSnackBar.show(
                  context,
                  title: state.title,
                  message: state.message,
                  isError: state.isError,
                ),
                buildWhen: (prev, curr) =>
                    prev.isLiked != curr.isLiked ||
                    prev.isLiking != curr.isLiking,
                builder: (context, state) => LoadingFAB(
                  loading: state.isLiking,
                  onPressed: () => context.read<FavouriteBloc>().add(
                    ToggleLike(
                      wall: state.isLiked ? null : widget.wallInfo,
                      favWall: state.isLiked
                          ? LocalDatabase.instance.getFavourite(
                              widget.wallInfo?.id ?? "",
                            )
                          : null,
                    ),
                  ),
                  child: Icon(
                    state.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: state.isLiked ? Colors.red : Colors.black,
                    size: state.isLiked ? 30 : 25,
                  ),
                ),
              ),

              AppConst.sizedBoxH10,

              // Author FAB:
              LoadingFAB(
                loading: false,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.transparent,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.wallInfo?.user?.profileImage?.large ??
                        widget.favouriteWall?.user?.profileImage?.large ??
                        "",
                  ),
                ),
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.portfolio,
                    queryParameters: {"userName": widget.wallInfo?.user},
                  );
                },
              ),

              AppConst.sizedBoxH10,

              ///  Speed dial FAB(edit,download,info):
              FloatingButtons(
                edit: Icon(Icons.edit, color: Colors.black),
                editPressed: () =>
                    context.read<ViewImageBloc>().add(EditingWall()),

                download: Icon(Icons.download, color: Colors.black),
                isDownloadLoading: state.isDownloading,
                downloadPressed: () => context.read<ViewImageBloc>().add(
                  DownloadWall(
                    boundaryKey: _previewController,
                    url: widget.wallInfo?.urls?.full,
                  ),
                ),

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
                size: 24,
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
}
