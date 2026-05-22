import 'dart:io';
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
  String? get _id => widget.wallInfo?.id ?? widget.favouriteWall?.id;
  String? get _fullUrl => widget.wallInfo?.urls?.full ?? widget.favouriteWall?.urls?.full;
  String? get _smallUrl => widget.wallInfo?.urls?.small ?? widget.favouriteWall?.urls?.small;
  String? get _profileImageLarge => widget.wallInfo?.user?.profileImage?.large ?? widget.favouriteWall?.user?.profileImage?.large;
  User? get _user => widget.wallInfo?.user ?? widget.favouriteWall?.user;

  late ImageProvider currentImageProvider;
  final GlobalKey _previewController = GlobalKey();

  @override
  void initState() {
    super.initState();
    final favId = _id ?? "";
    final localFav = LocalDatabase.instance.getFavourite(favId);
    final localFile = localFav?.imagePath != null ? File(localFav!.imagePath!) : null;

    if (localFile != null && localFile.existsSync()) {
      currentImageProvider = FileImage(localFile);
    } else {
      currentImageProvider = CachedNetworkImageProvider(_smallUrl ?? "");
      final fullImageUrl = _fullUrl;
      if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
        final fullImage = CachedNetworkImageProvider(fullImageUrl);
        fullImage.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((_, __) {
            if (mounted) {
              setState(() {
                currentImageProvider = fullImage;
              });
            }
          }),
        );
      }
    }
  }

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
            return const SizedBox.shrink();
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

              // Like FAB
              BlocConsumer<FavouriteBloc, FavouriteState>(
                listenWhen: (prev, curr) =>
                    curr is FavouriteLoaded &&
                    curr.snackMessage != null &&
                    (prev is! FavouriteLoaded || prev.snackMessage != curr.snackMessage),
                listener: (context, state) {
                  if (state is FavouriteLoaded && state.snackMessage != null) {
                    AppSnackBar.show(
                      context,
                      title: state.isErrorSnack == true ? "Error" : "Success",
                      message: state.snackMessage!,
                      isError: state.isErrorSnack == true,
                    );
                    context.read<FavouriteBloc>().add(ClearSnack());
                  }
                },
                buildWhen: (prev, curr) =>
                    curr is FavouriteLoaded || prev is FavouriteLoaded,
                builder: (context, state) {
                  final isLiked = state is FavouriteLoaded && state.favourites.any((f) => f.id == _id);
                  final isLiking = state is FavouriteLoaded && state.togglingFavId == _id;

                  return LoadingFAB(
                    loading: isLiking,
                    onPressed: () {
                      context.read<FavouriteBloc>().add(
                        ToggleLike(
                          wall: widget.wallInfo,
                          favWall: widget.favouriteWall,
                        ),
                      );
                    },
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                      size: isLiked ? 30 : 25,
                    ),
                  );
                },
              ),

              AppConst.sizedBoxH10,

              // Author FAB
              if (_profileImageLarge != null && _profileImageLarge!.isNotEmpty)
                LoadingFAB(
                  loading: false,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(_profileImageLarge!),
                  ),
                  onPressed: () {
                    if (_user != null) {
                      context.pushNamed(
                        AppRoutes.portfolio,
                        extra: _user,
                      );
                    }
                  },
                ),

              AppConst.sizedBoxH10,

              /// Speed dial FAB (edit, download, info)
              FloatingButtons(
                edit: const Icon(Icons.edit, color: Colors.black),
                editPressed: () =>
                    context.read<ViewImageBloc>().add(EditingWall()),

                download: const Icon(Icons.download, color: Colors.black),
                isDownloadLoading: state.isDownloading,
                downloadPressed: () => context.read<ViewImageBloc>().add(
                  DownloadWall(
                    boundaryKey: _previewController,
                    url: _fullUrl,
                  ),
                ),

                info: const Icon(Icons.info_outline, color: Colors.black),
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
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                );
              },
            ),

            BlocBuilder<ViewImageBloc, ViewImageState>(
              buildWhen: (prev, curr) => prev.blur != curr.blur,
              builder: (context, state) {
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
                if (state.editStatus != EditStatus.editing) {
                  return const SizedBox.shrink();
                }
                return const Positioned(
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
